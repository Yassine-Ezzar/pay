import 'dart:io';

void main() async {
  // Paths
  final screensDir = Directory('lib/screens'); // Adjust to your screens folder
  final mainFile = File('lib/main.dart'); // Adjust to your main.dart path
  final translationKeys = <String, String>{};

  // Step 1: Extract strings from all screens
  print('Extracting strings from screens...');
  final files = screensDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  for (var file in files) {
    String content = file.readAsStringSync();
    final newContent = content.replaceAllMapped(
      RegExp(r"Text\('([^']+)'(?:\s*,[^)]*)?\)"),
      (match) {
        String originalText = match.group(1)!;
        // Skip if the text is a variable or contains dynamic content
        if (originalText.contains(r'$') || originalText.contains('{')) {
          return match.group(0)!;
        }
        String key = originalText
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
            .replaceAll(RegExp(r'\s+'), '_');
        translationKeys[key] = originalText;
        return "TranslatedText('$key'${match.group(0)!.contains(',') ? ',' + match.group(0)!.split(',').sublist(1).join(',') : ''})";
      },
    );

    // Handle parameterized strings (e.g., 'Resend OTP in $_resendTimer s')
    final paramContent = newContent.replaceAllMapped(
      RegExp(r"Text\('([^']+)'(?:\s*,[^)]*)?\)"),
      (match) {
        String originalText = match.group(1)!;
        if (!originalText.contains(r'$')) return match.group(0)!;
        String key = originalText
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
            .replaceAll(RegExp(r'\s+'), '_')
            .replaceAll(RegExp(r'\$[a-z_]+'), '%0');
        translationKeys[key] = originalText.replaceAll(RegExp(r'\$[a-z_]+'), '%0');
        String param = originalText.contains(r'$') ? originalText.split(r'$')[1].split(' ')[0] : '';
        return "TranslatedText('$key', params: {'0': $param.toString()}${match.group(0)!.contains(',') ? ',' + match.group(0)!.split(',').sublist(1).join(',') : ''})";
      },
    );

    file.writeAsStringSync(paramContent);
  }

  // Step 2: Update AppTranslations in main.dart
  print('Updating AppTranslations in main.dart...');
  String mainContent = mainFile.readAsStringSync();
  final translationSectionStart = mainContent.indexOf("'en_US': {");
  final translationSectionEnd = mainContent.indexOf("'fr_FR': {", translationSectionStart);
  final existingEnTranslations = mainContent
      .substring(translationSectionStart + "'en_US': {".length, translationSectionEnd)
      .trim()
      .replaceAll('},', '');

  // Parse existing translations
  final existingKeys = <String, String>{};
  for (var line in existingEnTranslations.split('\n')) {
    if (line.trim().isNotEmpty) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        String key = parts[0].trim().replaceAll("'", '');
        String value = parts.sublist(1).join(':').trim().replaceAll("'", '').replaceAll(',', '');
        existingKeys[key] = value;
      }
    }
  }

  // Merge new keys
  translationKeys.addAll(existingKeys);

  // Generate updated translations
  final enTranslations = translationKeys.entries
      .map((entry) => "          '${entry.key}': '${entry.value}',")
      .join('\n');
  final frTranslations = translationKeys.entries
      .map((entry) => "          '${entry.key}': '${entry.value}',") // Placeholder for French
      .join('\n');

  // Replace the translations section in main.dart
  final updatedMainContent = mainContent.replaceRange(
    translationSectionStart + "'en_US': {".length,
    translationSectionEnd + "'fr_FR': {".length - 1,
    '\n$enTranslations\n        },\n        \'fr_FR\': {\n$frTranslations',
  );

  mainFile.writeAsStringSync(updatedMainContent);

  print('Localization update complete. Please manually translate French strings in main.dart.');
}