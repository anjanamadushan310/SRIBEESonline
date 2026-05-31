/// SRIBEESonline Flutter App - Default Entry Point
///
/// Delegates to the development configuration.
/// For other environments, use:
///   flutter run -t lib/main_staging.dart
///   flutter run -t lib/main_production.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_config.dart';
import 'config/sentry_service.dart';
import 'config/firebase_service.dart';
import 'core/providers/language_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Read the user-saved API URL (set via ServerConfigScreen on physical devices).
  final savedApiUrl = prefs.getString('custom_api_url');
  AppConfig.initialize(Environment.development, customApiUrl: savedApiUrl);

  await FirebaseService.initialize(optional: true);

  await SentryService.initialize(
    appRunner: () => runApp(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const SRIBEESonlineApp(),
      ),
    ),
  );
}
