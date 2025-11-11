import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/hive_service.dart';
import 'core/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mcwavftuydgkhdsboxpd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jd2F2ZnR1eWRna2hkc2JveHBkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2OTA2OTksImV4cCI6MjA3ODI2NjY5OX0.KjpxLjGwYtdyTug-VRtfCOipxPm2iJt4_17RLcbtcYg',
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.init();
  
  // Start background sync
  SyncService.startBackgroundSync();
  
  runApp(
    const ProviderScope(
      child: RaptorFittApp(),
    ),
  );
}

class RaptorFittApp extends ConsumerWidget {
  const RaptorFittApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Raptor.fitt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
