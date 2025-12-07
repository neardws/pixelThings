import 'package:flutter/material.dart';
import 'package:pixel_things/screens/main_screen.dart';
import 'package:pixel_things/core/utils/color_utils.dart';

class PixelThingsApp extends StatelessWidget {
  const PixelThingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Things',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PixelColors.background,
        colorScheme: ColorScheme.dark(
          primary: PixelColors.timeColor,
          surface: PixelColors.background,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
