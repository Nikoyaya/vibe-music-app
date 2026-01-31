import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/sp_util.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _currentLocale;
  String _languageCode = 'system';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Locale? get currentLocale => _currentLocale;
  String get languageCode => _languageCode;

  Future<void> _loadSavedLanguage() async {
    _languageCode = SpUtil.get<String>('language_code') ?? 'system';
    _updateLocale();
  }

  Future<void> changeLanguage(String code) async {
    _languageCode = code;
    await SpUtil.put('language_code', code);
    _updateLocale();
    // 更新应用的语言
    if (_currentLocale != null) {
      Get.updateLocale(_currentLocale!);
    } else {
      // 如果选择了系统语言，获取当前的系统语言并更新
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      Get.updateLocale(systemLocale);
    }
    notifyListeners();
  }

  void _updateLocale() {
    if (_languageCode == 'system') {
      _currentLocale = null; // 使用系统语言
    } else if (_languageCode == 'en') {
      _currentLocale = Locale('en');
    } else if (_languageCode == 'zh') {
      _currentLocale = Locale('zh');
    } else if (_languageCode == 'zh_TW') {
      _currentLocale = Locale('zh', 'TW');
    }
  }

  List<LanguageOption> get languageOptions => [
        LanguageOption('system', 'systemLanguage'),
        LanguageOption('en', 'english'),
        LanguageOption('zh', 'chinese'),
        LanguageOption('zh_TW', 'traditionalChinese'),
      ];
}

class LanguageOption {
  final String code;
  final String nameKey;

  LanguageOption(this.code, this.nameKey);
}
