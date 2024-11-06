import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final String fieldName;

  const CustomFormField({
    super.key,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          textInputAction: textInputAction,
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            prefixIcon: Icon(icon),
            hintText: hintText,
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                  // color: Colors.black,
                  ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
