import 'package:flutter/material.dart';

import '../constant/constants.dart';
import 'text_theme.dart';

final lightColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: seedColor,
  surface: Colors.blue[300],
);

final lightTheme = ThemeData().copyWith(
  scaffoldBackgroundColor: Colors.grey[80],
  colorScheme: lightColorScheme,
  textTheme: textTheme,
);
