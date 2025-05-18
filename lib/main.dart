import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:real_estate_app/router/app_router.dart';

void main() async {
  debugPrint('🚀 Application starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('📱 Flutter binding initialized');

  debugPrint('🔥 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('✅ Firebase initialized successfully');

  runApp(const ProviderScope(child: MainApp()));
  debugPrint('📱 MainApp started with ProviderScope');
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🏗️ Building MainApp widget');
    final router = ref.watch(appRouterProvider);
    debugPrint('🛣️ Router initialized');

    return MaterialApp.router(
      title: 'Emlak Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      routerConfig: router,
    );
  }
}
