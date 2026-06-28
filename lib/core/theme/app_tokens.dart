import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF102A43);
  static const interactive = Color(0xFF1479FF);
  static const accent = Color(0xFF19B9AD);
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF14213D);
  static const muted = Color(0xFF718096);
  static const outline = Color(0xFFE5EAF0);
  static const softBlue = Color(0xFFEAF3FF);
  static const softTurquoise = Color(0xFFE4F8F5);
  static const error = Color(0xFFBA1A1A);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const page = 20.0;
}

abstract final class AppRadii {
  static const small = BorderRadius.all(Radius.circular(12));
  static const medium = BorderRadius.all(Radius.circular(18));
  static const large = BorderRadius.all(Radius.circular(24));
  static const pill = BorderRadius.all(Radius.circular(999));
}

abstract final class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x120F2742), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
