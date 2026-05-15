import 'dart:io';

void main() {
  final libDir = Directory('c:/lara/www/kreatif-otopart/lib');
  if (!libDir.existsSync()) {
    print('Lib directory not found');
    return;
  }

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  final missingFiles = <String>{};

  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (final line in lines) {
      if (line.contains("import 'package:kreatif_otopart/")) {
        final match = RegExp("package:kreatif_otopart/(.*?\.dart)").firstMatch(line);
        if (match != null) {
          final relativePath = match.group(1)!;
          final fullPath = 'c:/lara/www/kreatif-otopart/lib/$relativePath';
          if (!File(fullPath).existsSync()) {
            missingFiles.add(relativePath);
          }
        }
      }
    }
  }

  if (missingFiles.isEmpty) {
    print('No missing internal files found.');
  } else {
    print('Missing internal files:');
    for (final missing in missingFiles) {
      print(missing);
    }
  }
}
