import 'package:flutter/material.dart';

void main() {
  runApp(const GalleryApp());
}

/// Entry point of the design system gallery.
///
/// The package root is itself the runnable app — there is no `example/`
/// directory. Every component added to this package gets a gallery entry here.
class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dabbler Design System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7328CE)),
        useMaterial3: true,
      ),
      home: const GalleryHomeScreen(),
    );
  }
}

/// A single entry in the gallery index.
class GalleryEntry {
  const GalleryEntry({required this.title, required this.builder});

  final String title;
  final WidgetBuilder builder;
}

/// The gallery index. Empty until components land; DS-000 only proves the
/// package runs.
const List<GalleryEntry> galleryEntries = <GalleryEntry>[];

class GalleryHomeScreen extends StatelessWidget {
  const GalleryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dabbler Design System')),
      body: galleryEntries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No components yet.\nAdd entries to galleryEntries as the '
                  'design system grows.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: galleryEntries.length,
              itemBuilder: (BuildContext context, int index) {
                final GalleryEntry entry = galleryEntries[index];
                return ListTile(
                  title: Text(entry.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: entry.builder),
                  ),
                );
              },
            ),
    );
  }
}
