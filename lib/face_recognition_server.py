import asyncio
import websockets
import cv2
import face_recognition
import numpy as np
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore, messaging

# Initialize Firebase Admin
cred = credentials.Certificate('cameye-9ae6a-firebase-adminsdk-46f82-fc897200db.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load the Haar Cascade for face detection
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

# Load authorized users from Firestore
def load_authorized_users_from_firestore():
    authorized_users = {}
    docs = db.collection('authorized_users').stream()
    for doc in docs:
        data = doc.to_dict()
        user_name = data['name']
        encodings = [np.array(enc) for enc in data['encodings']]
        authorized_users[user_name] = {
            'name': user_name,
            'encodings': encodings
        }
    return authorized_users

authorized_users = load_authorized_users_from_firestore()

# Match face encoding with known encodings
def match_face(known_encodings, face_encoding):
    matches = face_recognition.compare_faces(known_encodings, face_encoding)
    return True in matches

# Save data to Firestore
def save_to_firestore(user, frame, is_authorized):
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    img_name = f'{user}_{timestamp}.png'
    img_path = f'./{img_name}'
    cv2.imwrite(img_path, frame)
    entry_data = {
        'user': user,
        'timestamp': datetime.now(),
        'is_authorized': is_authorized,
        'image_path': img_path
    }
    db.collection('entries').add(entry_data)
    if not is_authorized:
        send_notification_to_admin(user, img_path)

# Send notification to admin
def send_notification_to_admin(user, img_path):
    message = messaging.Message(
        notification=messaging.Notification(
            title='Unauthorized Access Detected!',
            body=f'An unauthorized user {user} was detected.',
        ),
        data={
            'image_path': img_path,
            'user': user
        },
        topic='admin',
    )
    response = messaging.send(message)
    print(f'Notification sent to admin: {response}')

# Handle WebSocket clients
async def handle_client(websocket, path):
    print(f"New connection from {path}")
    cap = cv2.VideoCapture(0)
    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("Failed to capture image")
                break
            gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            gray_frame = cv2.equalizeHist(gray_frame)
            faces = face_cascade.detectMultiScale(gray_frame, scaleFactor=1.1, minNeighbors=3, minSize=(20, 20))
            for (x, y, w, h) in faces:
                face_crop = frame[y:y+h, x:x+w]
                rgb_face_crop = cv2.cvtColor(face_crop, cv2.COLOR_BGR2RGB)
                face_encodings = face_recognition.face_encodings(rgb_face_crop)
                if face_encodings:
                    face_encoding = face_encodings[0]
                    user_matched = None
                    is_authorized = False
                    for user, data in authorized_users.items():
                        if match_face(data['encodings'], face_encoding):
                            user_matched = data['name']
                            is_authorized = True
                            break
                    if not user_matched:
                        user_matched = 'Unknown'
                    save_to_firestore(user_matched, face_crop, is_authorized)
                    color = (0, 255, 0) if is_authorized else (0, 0, 255)
                    cv2.rectangle(frame, (x, y), (x+w, y+h), color, 2)
                    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    label = f'{user_matched} - {timestamp}'
                    cv2.putText(frame, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
            _, buffer = cv2.imencode('.jpg', frame)
            frame_data = buffer.tobytes()
            await websocket.send(frame_data)
            print("Sent frame to WebSocket client")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        cap.release()
        cv2.destroyAllWindows()
        print("WebSocket connection closed")

async def main():
    start_server = await websockets.serve(handle_client, "10.0.2.2", 6789)
    print("WebSocket server started on ws://10.0.2.2:6789")
    await start_server.wait_closed()

if __name__ == "__main__":
    asyncio.run(main())
