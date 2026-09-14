import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';
import 'data/models/product.dart';
import 'data/models/user_profile.dart';
import 'core/offline_sync/offline_sync_service.dart';
import 'core/offline_sync/services/upload_api.dart';
import 'core/config/api_config.dart';
import 'core/services/app_sound_service.dart';

Future<Box<T>> _openSafeBox<T>(String boxName) async {
  try {
    return await Hive.openBox<T>(boxName);
  } catch (e) {
    debugPrint('Resetting incompatible Hive box "$boxName": $e');
    try {
      await Hive.deleteBoxFromDisk(boxName);
    } catch (err) {
      debugPrint('Warning: Failed to delete box $boxName from disk: $err');
    }
    return await Hive.openBox<T>(boxName);
  }
}

/// Shown when startup fails, so the cause is visible on the device instead of
/// the process dying before it can draw anything.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.stage, required this.message});

  final String stage;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1B1B1B),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Startup failed',
                  style: TextStyle(
                    color: Color(0xFFFF8A80),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stage: $stage',
                  style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 15),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tracks how far startup got, so a failure names the stage that broke.
  var stage = 'EasyLocalization.ensureInitialized';
  try {
    // Drop cached copies so edited translations take effect on restart.
    rootBundle.evict('assets/translations/en.json');
    rootBundle.evict('assets/translations/hi.json');
    rootBundle.evict('assets/translations/ta.json');
    rootBundle.evict('assets/translations/bn.json');
    await EasyLocalization.ensureInitialized();

    stage = 'Hive.initFlutter';
    await Hive.initFlutter();

    stage = 'register Hive adapters';
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProductStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserProfileAdapter());
    }

    stage = 'open Hive boxes';
    await _openSafeBox<Product>('products_box');
    await _openSafeBox<String>('pending_sync_box');
    await _openSafeBox<UserProfile>('user_profile_box');
    await _openSafeBox('auth_box');
    await _openSafeBox('draft_box');
    await _openSafeBox('app_settings_box');

    stage = 'AppSoundService.init';
    await AppSoundService.instance.init();

    stage = 'ApiConfig.discoverWorkingUrl';
    final activeBaseUrl = await ApiConfig.discoverWorkingUrl();

    stage = 'OfflineSyncService.init';
    await OfflineSyncService.instance.init(
      uploadApi: RealUploadApi(baseUrl: activeBaseUrl),
      healthCheckUrl: '$activeBaseUrl/api/v1/health',
    );
  } catch (e, st) {
    debugPrint('STARTUP FAILURE at $stage: $e\n$st');
    runApp(_StartupErrorApp(stage: stage, message: '$e\n\n$st'));
    return;
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('ta'),
        Locale('bn'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const ProviderScope(
        child: HunarSetuApp(),
      ),
    ),
  );
}