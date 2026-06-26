// =============================================================================
// Dabbler — application shell
// -----------------------------------------------------------------------------
// Wires the resolved theme into MaterialApp (theme / darkTheme / themeMode) and
// maps the same colours into Forui via MaterialApp.builder. Also registers the
// debug-only Theme Gallery route.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'debug/theme_gallery.dart';
import 'theme/dabbler_colors.dart';
import 'theme/dabbler_forui_theme.dart';
import 'theme/theme_controller.dart';

class DabblerApp extends ConsumerWidget {
  const DabblerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Dabbler Design System',
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.themeMode,
      // Keep Forui in lock-step with whichever Material theme is active.
      builder: (context, child) => FTheme(
        data: dabblerForuiThemeData(Theme.of(context)),
        child: child!,
      ),
      routes: {
        if (kDebugMode) ThemeGalleryScreen.routeName: (_) => const ThemeGalleryScreen(),
      },
      home: const _HomeScreen(),
    );
  }
}

/// Minimal landing screen — proves section/override/mode all recolour, and (in
/// debug) opens the Theme Gallery acceptance check.
class _HomeScreen extends ConsumerWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final tokens = context.dabbler;
    final controller = ref.read(themeControllerProvider.notifier);
    final state = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dabbler')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Section → theme',
                  style: TextStyle(color: tokens.textSecondary),
                ),
                const SizedBox(height: 8),
                // Switching the section recolours the whole app via the
                // section→theme map (unless a user override is active).
                SegmentedButton<DabblerSection>(
                  segments: const [
                    ButtonSegment(value: DabblerSection.home, label: Text('Home')),
                    ButtonSegment(value: DabblerSection.sport, label: Text('Sport')),
                    ButtonSegment(value: DabblerSection.social, label: Text('Social')),
                    ButtonSegment(value: DabblerSection.active, label: Text('Active')),
                  ],
                  selected: {state.section},
                  onSelectionChanged: (s) => controller.setSection(s.first),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => controller.setThemeMode(
                    state.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: const Text('Toggle light / dark'),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(ThemeGalleryScreen.routeName),
                    child: const Text('Open Theme Gallery'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
