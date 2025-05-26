import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool isTranslated;
  final Map<String, String>? params;

  const TranslatedText(
    this.text, {
    this.style,
    this.textAlign,
    this.isTranslated = true,
    this.params,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTranslated) {
      final result = params != null ? _replaceParams(text, params!) : text;
      print('Displaying untranslated text: $result'); // Debug print
      return Text(
        result,
        style: style,
        textAlign: textAlign,
      );
    }

    String translatedText = params != null ? text.trParams(params!) : text.tr;
    print('Translating "$text" to "$translatedText" with locale: ${Get.locale}'); // Debug print

    return Text(
      translatedText,
      style: style,
      textAlign: textAlign,
    );
  }

  String _replaceParams(String text, Map<String, String> params) {
    String result = text;
    params.forEach((key, value) {
      result = result.replaceAll('%$key', value);
    });
    return result;
  }
}