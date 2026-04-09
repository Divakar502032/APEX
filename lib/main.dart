import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService().init();
  
  // Firebase initialization will go here shortly

  runApp(
    const ProviderScope(
      child: ApexApp(),
    ),
  );
}
