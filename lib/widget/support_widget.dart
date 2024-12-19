import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldTextFieldStyle() {
    return const TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold);
  }

  static TextStyle lightTextFieldStyle() {
    return const TextStyle(
        color: Colors.black54,
        fontSize: 20,
        fontWeight: FontWeight.w500);
  }

  static TextStyle semiboldTextFieldStyle() {
    return const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold);
  }
}