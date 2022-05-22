import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor background = MaterialColor(
    0xffeb6f2f2, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color> {
      50: Color(0xffb6f2f2),//10%
      100: Color(0xffa4dada),//20%
      200: Color(0xff92c2c2),//30%
      300: Color(0xff7fa9a9),//40%
      400: Color(0xff6d9191),//50%
      500: Color(0xff5b7979),//60%
      600: Color(0xff496161),//70%
      700: Color(0xff374949),//80%
      800: Color(0xff243030),//90%
      900: Color(0xff121818),//100%
    },
  );
}