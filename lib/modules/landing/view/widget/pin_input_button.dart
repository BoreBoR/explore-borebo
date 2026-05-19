import 'package:flutter/cupertino.dart';

Widget pinInputButton({
  required String digit,
  required VoidCallback onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      height: 60,

      decoration: BoxDecoration(
        color: const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xff1C1B1F),
          ),
        ),
      ),
    ),
  );
}
