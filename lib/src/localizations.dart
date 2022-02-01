import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../config.dart';

class MyLocalization {
  final Locale locale;
  MyLocalization(this.locale);

  static MyLocalization? of(BuildContext context) {
    return Localizations.of<MyLocalization>(context, MyLocalization);
  }

  Map<String, String> _localizedValues = Map();

  Future load() async {
    String jsonStringValues = await rootBundle.loadString("lib/languages/${locale.languageCode}.json");

    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

    _localizedValues = mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }


  String? getTranslatedValues(String key) {
    return _localizedValues[key];
  }

  static const LocalizationsDelegate<MyLocalization> delegate =
  _MyLocalizationsDelegate();
}

class _MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalization> {
  const _MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    for (Locale loc in Config.supportedLanguageList) {
      if (loc.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<MyLocalization> load(Locale locale) async {
    MyLocalization localization = MyLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_MyLocalizationsDelegate old) => false;
}
