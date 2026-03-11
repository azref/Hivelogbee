import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Added missing method
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  static double getCardSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 6;
    } else if (isTablet(context)) {
      return 8;
    } else {
      return 12;
    }
  }

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 3 : 2;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 4 : 3;
    } else {
      return 5;
    }
  }

  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1200;
    }
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = getScreenWidth(context);

    if (screenWidth < 360) {
      return baseFontSize * 0.8;
    } else if (screenWidth > 600) {
      return baseFontSize * 1.1;
    }

    return baseFontSize;
  }

  static double getIconSize(BuildContext context, double baseIconSize) {
    if (isMobile(context)) {
      return baseIconSize;
    } else if (isTablet(context)) {
      return baseIconSize * 1.2;
    } else {
      return baseIconSize * 1.4;
    }
  }

  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 36;
    } else if (isTablet(context)) {
      return 40;
    } else {
      return 44;
    }
  }

  static EdgeInsets getButtonPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    }
  }

  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else {
      return kToolbarHeight + 8;
    }
  }

  // Added missing method
  static Widget buildResponsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double? spacing,
  }) {
    final columns = responsiveValue(
      context: context,
      mobile: mobileColumns ?? 2,
      tablet: tabletColumns ?? 3,
      desktop: desktopColumns ?? 4,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: spacing ?? getCardSpacing(context),
      mainAxisSpacing: spacing ?? getCardSpacing(context),
      children: children,
    );
  }

  static Widget responsiveWidget({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints);
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? ResponsiveHelper.getScreenPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? ResponsiveHelper.getMaxWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final int? crossAxisCount;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final columns = crossAxisCount ?? ResponsiveHelper.getGridColumns(context);
    final cardSpacing = spacing ?? ResponsiveHelper.getCardSpacing(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: cardSpacing,
      mainAxisSpacing: runSpacing ?? cardSpacing,
      childAspectRatio: ResponsiveHelper.responsiveValue(
        context: context,
        mobile: 1.0,
        tablet: 1.1,
        desktop: 1.2,
      ),
      children: children,
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapOnMobile;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    if (wrapOnMobile && ResponsiveHelper.isMobile(context)) {
      return Wrap(
        spacing: ResponsiveHelper.getCardSpacing(context),
        runSpacing: ResponsiveHelper.getCardSpacing(context),
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle();
    final fontSize = baseStyle.fontSize ?? 11;
    final responsiveFontSize = ResponsiveHelper.getFontSize(context, fontSize);

    return Text(
      text,
      style: baseStyle.copyWith(fontSize: responsiveFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  const ResponsiveIcon(
      this.icon, {
        super.key,
        this.color,
        this.size,
      });

  @override
  Widget build(BuildContext context) {
    final baseSize = size ?? 16;
    final responsiveSize = ResponsiveHelper.getIconSize(context, baseSize);

    return Icon(
      icon,
      color: color,
      size: responsiveSize,
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveHelper.getButtonHeight(context);
    final buttonPadding = ResponsiveHelper.getButtonPadding(context);

    if (icon != null) {
      return SizedBox(
        height: buttonHeight,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: ResponsiveIcon(icon!),
          label: ResponsiveText(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            padding: buttonPadding,
          ),
        ),
      );
    }

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: buttonPadding,
        ),
        child: ResponsiveText(text),
      ),
    );
  }
}
