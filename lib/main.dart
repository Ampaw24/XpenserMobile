import 'package:expenser/core/router/app_router.dart';
import 'package:expenser/core/utils/theme/themes.dart';
import 'package:expenser/data/datasources/hive_service.dart';
import 'package:expenser/firebase_options.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
  await HiveService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isDark = ref.watch(settingsProvider.select((s) => s.isDarkMode));

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Xpenser',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
