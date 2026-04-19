import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonUI {
  CommonUI();

  // Color Palette - The Vitality Edit
  final Color surface = const Color(0xFFF6FAFA);
  final Color surfaceContainerLow = const Color(0xFFF1F4F4);
  final Color surfaceContainer = const Color(0xFFEBEEEF);
  final Color surfaceContainerHigh = const Color(0xFFE5E9E9);
  final Color surfaceContainerHighest = const Color(0xFFDFE3E3);
  final Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  
  final Color primary = const Color(0xFF006067);
  final Color primaryContainer = const Color(0xFF007b83);
  final Color onPrimaryContainer = const Color(0xFFd0fbff);
  final Color primaryFixed = const Color(0xFF96f1fa);
  final Color primaryFixedDim = const Color(0xFF7ad5dd);

  final Color secondary = const Color(0xFF006c48);
  final Color secondaryContainer = const Color(0xFF92f7c3);
  final Color onSecondaryContainer = const Color(0xFF00734d);
  final Color secondaryFixedDim = const Color(0xFF75daa8);

  final Color onSurface = const Color(0xFF181C1D);
  final Color onSurfaceVariant = const Color(0xFF3E494A);
  
  final Color outlineVariant = const Color(0xFFBDC9CA);
  
  final Color error = const Color(0xFFba1a1a);
  final Color onError = const Color(0xFFFFFFFF);

  // BoxDecorations
  BoxDecoration get bodyBoxDecorator => BoxDecoration(
    color: surface,
  );

  BoxDecoration get cardDecorator => BoxDecoration(
    color: surfaceContainerLowest,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 96, 103, 0.06),
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
    ],
  );

  BoxDecoration get floatingNavDecorator => BoxDecoration(
    color: const Color(0xCCF6FAFA),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 96, 103, 0.06),
        blurRadius: 32,
        offset: Offset(0, -12),
      ),
    ],
  );

  final textEditingFieldDecoration = InputDecoration(
    hintText: 'Weight (kg)',
    hintStyle: GoogleFonts.inter(color: const Color(0xFF3E494A)),
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
    ),
    focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF006067), width: 2),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
    ),
  );

  final textEditingField = const TextInputType.numberWithOptions(decimal: true);

  final inputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,3})?$')),
  ];

  Color get scaffoldBackgroundColor => surface;
  Color get textColorDefault => onSurface;
  Color get weightGainColor => error;
  Color get weightLossColor => secondary;
  
  double get mainHeadingSize => 24.0;
  double get mediumHeadingSize => 18.0;
  double get subHeadingSize => 14.0;

  BoxDecoration get bodyCircleDecorator => BoxDecoration(
    color: surface,
    shape: BoxShape.circle,
  );

  ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 4,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
  );
}