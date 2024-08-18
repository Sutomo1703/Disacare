import 'package:disacare/style/color.dart';
import 'package:flutter/material.dart';

final ButtonStyle lihatberitabutton = ElevatedButton.styleFrom(
  minimumSize: const Size(85, 35),
  backgroundColor: blue,
  elevation: 0,
);

final ButtonStyle pilihgambarbutton = ElevatedButton.styleFrom(
    minimumSize: const Size(85, 30),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6.0),
    ),
    backgroundColor: grey,
    elevation: 0);

final ButtonStyle recordbutton = ElevatedButton.styleFrom(
  minimumSize: const Size(30, 30),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5.0),
  ),
  backgroundColor: blue,
  elevation: 0,
);
