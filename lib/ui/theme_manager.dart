import 'package:google_fonts/google_fonts.dart';
import 'package:neffils/ui/color_manager.dart';
import 'package:neffils/ui/font_manager.dart';
import 'package:neffils/ui/styles_manager.dart';
import 'package:neffils/ui/values_manager.dart';
import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    // main colors of the app
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.primaryOpacity70,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: ColorManager.grey1,
    // ripple color
    splashColor: ColorManager.primaryOpacity70,
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(
          Colors.white,
        ), // default icon color
      ),
    ),
    // card view theme
    cardTheme: CardThemeData(
      color: ColorManager.white,
      shadowColor: ColorManager.grey,
      elevation: AppSize.s4,
    ),
    // App bar theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      color: ColorManager.primary,
      elevation: AppSize.s4,
      shadowColor: ColorManager.primaryOpacity70,
      titleTextStyle: getMediumStyle(
        color: ColorManager.white,
        fontSize: FontSize.s18,
      ),
    ),
    // Button theme
    buttonTheme: ButtonThemeData(
      shape: const StadiumBorder(),
      disabledColor: ColorManager.primary,
      buttonColor: ColorManager.primary,
      splashColor: ColorManager.primaryOpacity70,
    ),

    // elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: getRegularStyle(color: ColorManager.white),
        backgroundColor: ColorManager.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12),
        ),
      ),
    ),

    // Text theme
    textTheme: GoogleFonts.poppinsTextTheme(),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ColorManager.primary,
    ),

    // input decoration theme (text form field)
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,

      iconColor: ColorManager.primary,
      // focusColor: ColorManager.primary,
      contentPadding: const EdgeInsets.all(AppPadding.p16),
      // hint style
      hintStyle: getRegularStyle(color: ColorManager.grey1),

      // label style
      labelStyle: getMediumStyle(color: ColorManager.darkGrey),
      // error style
      errorStyle: getRegularStyle(color: ColorManager.error),
      errorMaxLines: 3,
      filled: true,
      fillColor: ColorManager.white,

      // enabled border
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.grey, width: AppSize.s0_5),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),

      // focused border
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.primary,
          width: AppSize.s0_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),

      // error border
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.error, width: AppSize.s0_5),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
      // focused error border
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.primary,
          width: AppSize.s0_5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: ColorManager.grey,
    ),
    focusColor: ColorManager.primary,
    dividerColor: ColorManager.primary,
    tabBarTheme: TabBarThemeData(indicatorColor: ColorManager.primary),
  );
}
