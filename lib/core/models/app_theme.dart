import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final String name;
  final Color timeColor;
  final Color secondsColor;
  final Color weekActiveColor;
  final Color weekInactiveColor;
  final Color backgroundColor;
  final Color effectPrimaryColor;
  final Color effectSecondaryColor;

  const AppTheme({
    required this.id,
    required this.name,
    required this.timeColor,
    required this.secondsColor,
    required this.weekActiveColor,
    required this.weekInactiveColor,
    this.backgroundColor = const Color(0xFF000000),
    required this.effectPrimaryColor,
    required this.effectSecondaryColor,
  });

  AppTheme copyWith({
    String? id,
    String? name,
    Color? timeColor,
    Color? secondsColor,
    Color? weekActiveColor,
    Color? weekInactiveColor,
    Color? backgroundColor,
    Color? effectPrimaryColor,
    Color? effectSecondaryColor,
  }) {
    return AppTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      timeColor: timeColor ?? this.timeColor,
      secondsColor: secondsColor ?? this.secondsColor,
      weekActiveColor: weekActiveColor ?? this.weekActiveColor,
      weekInactiveColor: weekInactiveColor ?? this.weekInactiveColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      effectPrimaryColor: effectPrimaryColor ?? this.effectPrimaryColor,
      effectSecondaryColor: effectSecondaryColor ?? this.effectSecondaryColor,
    );
  }
}

class AppThemes {
  static const matrixGreen = AppTheme(
    id: 'matrix_green',
    name: 'Matrix Green',
    timeColor: Color(0xFF00FF00),
    secondsColor: Color(0xFF00CC00),
    weekActiveColor: Color(0xFF00FF00),
    weekInactiveColor: Color(0xFF004400),
    effectPrimaryColor: Color(0xFF00FF00),
    effectSecondaryColor: Color(0xFF003300),
  );

  static const cyberBlue = AppTheme(
    id: 'cyber_blue',
    name: 'Cyber Blue',
    timeColor: Color(0xFF00AAFF),
    secondsColor: Color(0xFF0088CC),
    weekActiveColor: Color(0xFF00AAFF),
    weekInactiveColor: Color(0xFF003355),
    effectPrimaryColor: Color(0xFF00AAFF),
    effectSecondaryColor: Color(0xFF002244),
  );

  static const sunsetOrange = AppTheme(
    id: 'sunset_orange',
    name: 'Sunset Orange',
    timeColor: Color(0xFFFF6600),
    secondsColor: Color(0xFFFF4400),
    weekActiveColor: Color(0xFFFF6600),
    weekInactiveColor: Color(0xFF442200),
    effectPrimaryColor: Color(0xFFFF6600),
    effectSecondaryColor: Color(0xFF331100),
  );

  static const neonPink = AppTheme(
    id: 'neon_pink',
    name: 'Neon Pink',
    timeColor: Color(0xFFFF00FF),
    secondsColor: Color(0xFFCC00CC),
    weekActiveColor: Color(0xFFFF00FF),
    weekInactiveColor: Color(0xFF440044),
    effectPrimaryColor: Color(0xFFFF00FF),
    effectSecondaryColor: Color(0xFF220022),
  );

  static const pureWhite = AppTheme(
    id: 'pure_white',
    name: 'Pure White',
    timeColor: Color(0xFFFFFFFF),
    secondsColor: Color(0xFFCCCCCC),
    weekActiveColor: Color(0xFFFFFFFF),
    weekInactiveColor: Color(0xFF444444),
    effectPrimaryColor: Color(0xFFFFFFFF),
    effectSecondaryColor: Color(0xFF333333),
  );

  static const retroAmber = AppTheme(
    id: 'retro_amber',
    name: 'Retro Amber',
    timeColor: Color(0xFFFFAA00),
    secondsColor: Color(0xFFCC8800),
    weekActiveColor: Color(0xFFFFAA00),
    weekInactiveColor: Color(0xFF443300),
    effectPrimaryColor: Color(0xFFFFAA00),
    effectSecondaryColor: Color(0xFF221100),
  );

  static List<AppTheme> get all => [
    matrixGreen,
    cyberBlue,
    sunsetOrange,
    neonPink,
    pureWhite,
    retroAmber,
  ];

  static AppTheme getById(String id) {
    return all.firstWhere(
      (theme) => theme.id == id,
      orElse: () => matrixGreen,
    );
  }
}
