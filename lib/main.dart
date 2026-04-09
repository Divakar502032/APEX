import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization will go here shortly

  runApp(
    const ProviderScope(
      child: ApexApp(),
    ),
  );
}
