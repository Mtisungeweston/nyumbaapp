import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'router/app_router.dart';
import 'theme/theme.dart';
import 'services/fcm_service.dart';
import 'services/connectivity_service.dart';
import 'screens/splash_screen.dart';
import 'screens/firebase_setup_error_screen.dart';
import 'widgets/network_status_widget.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    developer.log('[NYUMBA] Initialization starting', name: 'main');
    
    // Initialize connectivity immediately (lightweight)
    final connectivityService = ConnectivityService();
    connectivityService.initialize();
    developer.log('[NYUMBA] Connectivity service initialized', name: 'main');
    
    // Initialize Firebase (must wait for it)
    await FirebaseConfig.initialize();
    developer.log('[NYUMBA] Firebase initialization completed', name: 'main');
    
    // Initialize FCM if Firebase succeeded
    if (FirebaseConfig.isInitialized) {
      FCMService().initialize().then((_) {
        developer.log('[NYUMBA] FCM initialized', name: 'main');
      }).catchError((e) {
        developer.log('[NYUMBA] FCM init error (non-critical): $e', name: 'main');
      });
    }
    
  } catch (e, stackTrace) {
    developer.log('[NYUMBA] Init error: $e', name: 'main', error: e, stackTrace: stackTrace);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  Future<void> _initializeSplash() async {
    // Show splash for minimum 1.5 seconds for UX
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _splashDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show Firebase setup error if initialization failed
    if (FirebaseConfig.initializationFailed) {
      return MaterialApp(
        title: 'Nyumba',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: FirebaseSetupErrorScreen(
          errorMessage: FirebaseConfig.initializationError,
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Nyumba',
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.getRouter(authProvider.isAuthenticated),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              if (!_splashDone) {
                return const SplashScreen();
              }
              return NetworkStatusWidget(
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
