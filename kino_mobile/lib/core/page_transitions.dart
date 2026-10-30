import 'package:flutter/material.dart';

/// Transição suave entre telas: fade + pequeno deslize lateral.
class KinoPageTransitionsBuilder extends PageTransitionsBuilder {
  const KinoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Aplica a transição acima a todas as plataformas.
const PageTransitionsTheme kinoPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: KinoPageTransitionsBuilder(),
    TargetPlatform.iOS: KinoPageTransitionsBuilder(),
    TargetPlatform.windows: KinoPageTransitionsBuilder(),
    TargetPlatform.linux: KinoPageTransitionsBuilder(),
    TargetPlatform.macOS: KinoPageTransitionsBuilder(),
    TargetPlatform.fuchsia: KinoPageTransitionsBuilder(),
  },
);
