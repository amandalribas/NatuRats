import 'package:flutter/material.dart';

class GroupTextField extends StatefulWidget {
  const GroupTextField({super.key, required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  State<GroupTextField> createState() => _GroupTextFieldState();
}

class _GroupTextFieldState extends State<GroupTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(),
      ),
    );
  }
}