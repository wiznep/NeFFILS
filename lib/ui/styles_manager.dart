import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neffils/ui/color_manager.dart';

import 'font_manager.dart';

TextStyle getTextStyle(
  double fontSize,
  String fontFamily,
  FontWeight fontWeight,
  Color? color,
) {
  return GoogleFonts.poppins(
    fontSize: fontSize,
    color: color ?? ColorManager.darkText,
    fontWeight: fontWeight,
  );
}

// regular style
TextStyle getRegularStyle({double fontSize = FontSize.s12, Color? color}) {
  return getTextStyle(
    fontSize,
    FontConstants.fontFamily,
    FontWeightManager.regular,
    color ?? ColorManager.darkText,
  );
}

// light text style
TextStyle getLightStyle({double fontSize = FontSize.s12, Color? color}) {
  return getTextStyle(
    fontSize,
    FontConstants.fontFamily,
    FontWeightManager.light,
    color ?? ColorManager.darkText,
  );
}

// bold text style
TextStyle getBoldStyle({double fontSize = FontSize.s12, Color? color}) {
  return getTextStyle(
    fontSize,
    FontConstants.fontFamily,
    FontWeightManager.bold,
    color ?? ColorManager.darkText,
  );
}

// semi bold text style
TextStyle getSemiBoldStyle({double fontSize = FontSize.s12, Color? color}) {
  return getTextStyle(
    fontSize,
    FontConstants.fontFamily,
    FontWeightManager.semiBold,
    color ?? ColorManager.darkText,
  );
}

// medium text style
TextStyle getMediumStyle({double fontSize = FontSize.s12, Color? color}) {
  return getTextStyle(
    fontSize,
    FontConstants.fontFamily,
    FontWeightManager.medium,
    color ?? ColorManager.darkText,
  );
}

TextStyle getItalicsStyle({
  double fontSize = FontSize.s12,
  Color? color,
  FontWeight? fontWeight,
}) {
  return getTextStyle(
    fontSize,
    FontConstants.fontFamily,
    fontWeight ?? FontWeightManager.regular,
    color ?? ColorManager.darkText,
  ).copyWith(fontStyle: FontStyle.italic);
}
