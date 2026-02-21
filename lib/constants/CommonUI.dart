import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonUI {

  CommonUI();

  final bodyBoxDecorator = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFF7043),
        const Color(0xFFFF9043),
        ?Colors.red[100],
        const Color(0xFFFFFFFF)
      ],
      stops: const [0.0, 0.7, 0.9, 1.0],
    ),
    borderRadius: const BorderRadius.all(Radius.circular(12)),
  );

  final bodyCircleDecorator = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFF7043),
        const Color(0xFFFF9043),
        ?Colors.red[100],
        const Color(0xFFFFFFFF)
      ],
      stops: const [0.0, 0.7, 0.9, 1.0],
    ),
  );

  final textEditingFieldDecoration = const InputDecoration(
    hintText: 'Weight (kg)',
    hintStyle: TextStyle(color: Colors.black87),
    isDense: true, // smaller height
    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white54),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  );

  final elevatedButtonStyle =  ElevatedButton.styleFrom(
  backgroundColor: Colors.lightGreenAccent[100], // or primary theme color
  foregroundColor: Colors.white,
  elevation: 6,
  padding: const EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 14,
  ),
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(25),
  ),
  );

  final textEditingField = TextInputType
          .numberWithOptions(
          decimal: true);

  final inputFormatter = [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d{0,3}(\.\d{0,3})?$'),),
      ];

  final scaffoldBackgroundColor = Colors.deepOrange[100];

  final mainHeadingSize = 20.0;
  final mediumHeadingSize = 18.0;
  final subHeadingSize = 16.0;

  final weightGainColor = Colors.red[900];
  final weightLossColor = Colors.green[800];
  final textColorDefault = Colors.black;

}