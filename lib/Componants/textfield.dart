import 'package:flutter/material.dart';

class Mytextfield extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final bool obscuretext;


  const Mytextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscuretext,
});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscuretext,
      decoration: InputDecoration(
          hintText: hintText
      ),
    );
  }
}
