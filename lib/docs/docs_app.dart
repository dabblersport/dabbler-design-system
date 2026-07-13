// =============================================================================
// Dabbler Docs — application
// -----------------------------------------------------------------------------
// The public documentation site. MaterialApp.router with hash-based deep links;
// the control state (theme / brightness / direction) and the router are exposed
// to the whole tree so the shell and every page can read them.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_theme_data.dart';
import 'doc_controls.dart';
import 'doc_router.dart';
import 'doc_shell.dart';

class DocsApp extends StatefulWidget {
  const DocsApp({super.key});

  @override
  State<DocsApp> createState() => _DocsAppState();
}

class _DocsAppState extends State<DocsApp> {
  final DocControls _controls = DocControls();
  final DocRouteParser _parser = DocRouteParser();
  late final DocRouterDelegate _delegate =
      DocRouterDelegate((path) => DocShell(path: path));

  @override
  void dispose() {
    _controls.dispose();
    _delegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dabbler Design System',
      debugShowCheckedModeBanner: false,
      theme: dabblerThemeData(DabblerTheme.main, Brightness.light),
      routerDelegate: _delegate,
      routeInformationParser: _parser,
      builder: (context, child) => DocControlsScope(
        controls: _controls,
        child: DocRouterScope(delegate: _delegate, child: child!),
      ),
    );
  }
}
