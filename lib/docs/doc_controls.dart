// =============================================================================
// Dabbler Docs — global preview controls
// -----------------------------------------------------------------------------
// The header's theme / light-dark / LTR-RTL switches live here and are exposed
// to the whole app via an InheritedNotifier, so every live example on every page
// re-renders in the selected theme, brightness, and direction.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';

class DocControls extends ChangeNotifier {
  DabblerTheme _theme = DabblerTheme.main;
  Brightness _brightness = Brightness.light;
  bool _rtl = false;

  DabblerTheme get theme => _theme;
  Brightness get brightness => _brightness;
  bool get rtl => _rtl;

  Locale get locale => Locale(_rtl ? 'ar' : 'en');
  TextDirection get textDirection =>
      _rtl ? TextDirection.rtl : TextDirection.ltr;

  set theme(DabblerTheme v) {
    if (_theme != v) {
      _theme = v;
      notifyListeners();
    }
  }

  set brightness(Brightness v) {
    if (_brightness != v) {
      _brightness = v;
      notifyListeners();
    }
  }

  void toggleBrightness() => brightness =
      _brightness == Brightness.dark ? Brightness.light : Brightness.dark;

  set rtl(bool v) {
    if (_rtl != v) {
      _rtl = v;
      notifyListeners();
    }
  }

  void toggleRtl() => rtl = !_rtl;
}

/// Exposes [DocControls] to descendants; rebuilds them when a control changes.
class DocControlsScope extends InheritedNotifier<DocControls> {
  const DocControlsScope({
    super.key,
    required DocControls controls,
    required super.child,
  }) : super(notifier: controls);

  static DocControls of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DocControlsScope>();
    assert(scope != null, 'DocControlsScope not found in context');
    return scope!.notifier!;
  }
}
