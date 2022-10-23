import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget userGender(gender) {
  switch (gender) {
    case 'Male':
      return const Icon(
        FontAwesomeIcons.mars,
        color: Colors.white,
      );
    case 'Female':
      return const Icon(
        FontAwesomeIcons.venus,
        color: Colors.white,
      );
    case 'Transgender':
      return const Icon(
        FontAwesomeIcons.transgender,
        color: Colors.white,
      );
    default:
      return Container();
  }
}
