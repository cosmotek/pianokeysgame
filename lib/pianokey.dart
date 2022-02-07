
import 'package:flutter/material.dart';

Widget PianoKey({ required bool isNote, required bool isErrored, required int rowNumber, double keyWidth = 100, double keyHeight = 175 }) =>
  Container(
    margin: const EdgeInsets.only(
      bottom: 0.5,
      left: 0.3,
      right: 0.3,
    ),
    padding: EdgeInsets.only(
      top: 0,
      left: keyWidth * .03,
      right: keyWidth * .03,
      bottom: keyHeight * .05,
    ),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(5),
        bottomRight: Radius.circular(5),
      ),
      color: getColorAccent(
        isNote: isNote,
        isErrored: isErrored,
      ),
    ),
    width: keyWidth,
    height: keyHeight,
    child: Container(
      width: keyWidth,
      height: keyHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        color: getColor(
          isNote: isNote,
          isErrored: isErrored,
        ),
      ),
      child: (rowNumber == 0  && isNote)
        ? const Center(child: Text(
            "START",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )
          ))
        : null,
    ),
  );

Color getColor({ required bool isNote, required isErrored }) {
  if (isErrored) {
    return Colors.red;
  }

  if (isNote) {
    return Colors.lightBlue;
  }

  return Colors.white;
}

Color getColorAccent({ required bool isNote, required isErrored }) {
  if (isErrored) {
    return Colors.red;
  }

  if (isNote) {
    return Colors.blue;
  }

  return Colors.grey[100]!;
}