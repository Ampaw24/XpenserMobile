import 'package:flutter/material.dart';

/// Borderless, unfilled input for fields placed inside an existing surface.
InputDecoration bareInputDecoration({
  required String hintText,
  required TextStyle hintStyle,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: hintStyle,
    filled: false,
    isDense: true,
    contentPadding: EdgeInsets.zero,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
  );
}
