import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Settings {
  String logLevel;
  bool adBlockEnabled;
  bool proxyShareEnabled;
  String selectedDNS;

  Settings({
    this.logLevel = 'warn',
    this.adBlockEnabled = false,
    this.proxyShareEnabled = false,
    this.selectedDNS = 'Google',
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      logLevel: json['logLevel'] ?? 'warn',
      adBlockEnabled: json['adBlockEnabled'] ?? false,
      proxyShareEnabled: json['proxyShareEnabled'] ?? false,
      selectedDNS: json['selectedDNS'] ?? 'Google',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logLevel': logLevel,
      'adBlockEnabled': adBlockEnabled,
      'proxyShareEnabled': proxyShareEnabled,
      'selectedDNS': selectedDNS,
    };
  }
}

class SettingsManager {
  static const String _fileName = 'begzar_settings.json';
  static Settings? _cachedSettings;

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  static Future<Settings> loadSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return Settings();
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      _cachedSettings = Settings.fromJson(json);
      return _cachedSettings!;
    } catch (e) {
      print('Error loading settings: $e');
      return Settings();
    }
  }

  static Future<void> saveSettings(Settings settings) async {
    try {
      final file = await _localFile;
      final json = settings.toJson();
      await file.writeAsString(jsonEncode(json));
      _cachedSettings = settings;
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  static Future<void> updateSettings({
    String? logLevel,
    bool? adBlockEnabled,
    bool? proxyShareEnabled,
    String? selectedDNS,
  }) async {
    final settings = await loadSettings();
    
    if (logLevel != null) settings.logLevel = logLevel;
    if (adBlockEnabled != null) settings.adBlockEnabled = adBlockEnabled;
    if (proxyShareEnabled != null) settings.proxyShareEnabled = proxyShareEnabled;
    if (selectedDNS != null) settings.selectedDNS = selectedDNS;

    await saveSettings(settings);
  }
} 