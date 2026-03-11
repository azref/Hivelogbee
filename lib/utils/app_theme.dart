import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color honeyOrange = Color(0xFFFF8C00);
  static const Color darkBrown = Color(0xFF8B4513);
  static const Color lightBrown = Color(0xFFD2B48C);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  // Added missing colors
  static const Color lightYellow = Color(0xFFFFF8E1);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static const TextStyle tinyText = TextStyle(
    fontSize: 8,
    color: darkBrown,
  );

  static const TextStyle smallText = TextStyle(
    fontSize: 10,
    color: darkBrown,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 11,
    color: darkBrown,
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 9,
    color: darkBrown,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleText = TextStyle(
    fontSize: 12,
    color: darkBrown,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headerText = TextStyle(
    fontSize: 14,
    color: darkBrown,
    fontWeight: FontWeight.bold,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.amber,
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: backgroundColor, // Corrected
      fontFamily: 'Cairo',
      textTheme: const TextTheme(
        displayLarge: headerText,
        displayMedium: titleText,
        displaySmall: bodyText,
        headlineLarge: headerText,
        headlineMedium: titleText,
        headlineSmall: bodyText,
        titleLarge: titleText,
        titleMedium: bodyText,
        titleSmall: labelText,
        bodyLarge: bodyText,
        bodyMedium: smallText,
        bodySmall: tinyText,
        labelLarge: labelText,
        labelMedium: smallText,
        labelSmall: tinyText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryYellow,
        foregroundColor: darkBrown,
        elevation: 0,
        titleTextStyle: titleText,
        toolbarTextStyle: bodyText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: darkBrown,
          textStyle: labelText,
          elevation: 0,
          shape: const RoundedRectangleBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryYellow,
          textStyle: labelText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        filled: false,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: labelText,
        hintStyle: smallText,
        errorStyle: tinyText,
      ),
      cardTheme: const CardThemeData( // Corrected to CardThemeData
        elevation: 0,
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        minVerticalPadding: 2,
        titleTextStyle: bodyText,
        subtitleTextStyle: smallText,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        disabledColor: Colors.transparent,
        selectedColor: primaryYellow.withAlpha(51), // Adjusted for opacity
        secondarySelectedColor: primaryYellow.withAlpha(51), // Adjusted for opacity
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        labelStyle: tinyText,
        secondaryLabelStyle: tinyText,
        brightness: Brightness.light,
        elevation: 0,
        pressElevation: 0,
        shape: const RoundedRectangleBorder(),
      ),
      tabBarTheme: const TabBarThemeData( // Corrected to TabBarThemeData
        labelColor: primaryYellow,
        unselectedLabelColor: Colors.grey,
        labelStyle: smallText,
        unselectedLabelStyle: tinyText,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryYellow, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryYellow,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: tinyText,
        unselectedLabelStyle: tinyText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: darkBrown,
        elevation: 0,
        highlightElevation: 0,
      ),
      dialogTheme: const DialogThemeData( // Corrected to DialogThemeData
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(),
        titleTextStyle: titleText,
        contentTextStyle: bodyText,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkBrown,
        contentTextStyle: smallText,
        elevation: 0,
        shape: RoundedRectangleBorder(),
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      textTheme: lightTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }

  static BoxDecoration get flatDecoration {
    return const BoxDecoration(
      color: Colors.transparent,
    );
  }

  static BoxDecoration get gradientDecoration {
    return const BoxDecoration(
      color: Colors.white,
    );
  }
}
