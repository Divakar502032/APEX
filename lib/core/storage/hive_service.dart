import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hiveServiceProvider = Provider((ref) => HiveService());

class HiveBoxNames {
  static const String userPrefs = 'user_prefs';
  static const String memories = 'memories_cache';
  static const String settings = 'app_settings';
}

class HiveService {
  /// Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Open core boxes
    await Hive.openBox(HiveBoxNames.userPrefs);
    await Hive.openBox(HiveBoxNames.memories);
    await Hive.openBox(HiveBoxNames.settings);
    
    if (kDebugMode) {
      print('📦 Hive Initialized');
    }
  }

  // ─── User Preference Helpers ───────────────────────────────────────────────

  Future<void> saveUserName(String name) async {
    final box = Hive.box(HiveBoxNames.userPrefs);
    await box.put('name', name);
  }

  String? getUserName() {
    final box = Hive.box(HiveBoxNames.userPrefs);
    return box.get('name') as String?;
  }

  Future<void> saveUserPref({
    required String key,
    required dynamic value,
  }) async {
    final box = Hive.box(HiveBoxNames.userPrefs);
    await box.put(key, value);
  }

  dynamic getUserPref(String key) {
    final box = Hive.box(HiveBoxNames.userPrefs);
    return box.get(key);
  }

  // ─── App Settings ─────────────────────────────────────────────────────────

  Future<void> setHasSeenOnboarding(bool value) async {
    final box = Hive.box(HiveBoxNames.settings);
    await box.put('has_seen_onboarding', value);
  }

  bool hasSeenOnboarding() {
    final box = Hive.box(HiveBoxNames.settings);
    return box.get('has_seen_onboarding', defaultValue: false) as bool;
  }

  // ─── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await Hive.box(HiveBoxNames.userPrefs).clear();
    await Hive.box(HiveBoxNames.memories).clear();
    await Hive.box(HiveBoxNames.settings).clear();
  }
}
