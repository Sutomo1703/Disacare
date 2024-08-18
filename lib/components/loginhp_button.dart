import 'package:flutter/material.dart';

class PhoneButton extends StatelessWidget {

  final Function()? onTap;

  const PhoneButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 15),
        decoration: BoxDecoration(
          color: Colors.grey[500],
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text('Login Nomor HP', style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),),
        ),
      ),
    );
  }
}