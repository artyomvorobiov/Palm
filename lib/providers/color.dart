import 'package:flutter/material.dart';

class ColorTheme with ChangeNotifier {
  int darkColor = 0xFF40E0D0;
  int secdarkColor = 0xFF001e40;

  int lightColor = 0xFFFF8B00;
  int secLightColor = 0xFFFFECDD;

  static int mainFirstColor = 0xFF40E0D0, mainSecColor = 0xFF001e40;
  void switchTheme(bool isDarkTheme) {
    mainFirstColor = isDarkTheme ? darkColor : lightColor;
    mainSecColor = isDarkTheme ? secdarkColor : secLightColor;
    notifyListeners();
  }

  int get currentFirstColor {
    return mainFirstColor;
  }

  int get currentSecondColor {
    return mainSecColor;
  }
}
