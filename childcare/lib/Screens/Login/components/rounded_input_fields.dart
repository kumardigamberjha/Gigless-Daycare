import 'package:childcare/Screens/Login/components/text_field_container.dart';
import 'package:childcare/constant.dart';
import 'package:flutter/material.dart';

class RoundedInputField extends StatelessWidget {
  final String hintType;
  final IconData icon;
  final ValueChanged<String> onChange;
  final TextEditingController controller;
  final String? Function(dynamic value) validator; // Move validator here
  final TextInputType? keyboardType;

  const RoundedInputField({
    Key? key, // Use key here instead of super.key
    required this.hintType,
    this.icon = Icons.person,
    required this.onChange,
    required this.controller,
    required this.validator, // Add validator here
    required this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        // Use TextFormField instead of TextField
        onChanged: onChange,
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: KPrimaryColor,
          ),
          hintText: hintType,
          border: InputBorder.none,
        ),
        validator: validator, // Pass the validator to TextFormField
      ),
    );
  }
}
