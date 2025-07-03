import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/core/services/connected_internet.dart';
import 'package:foodapp/network_status_overlay.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:foodapp/core/firebase_options.dart';
import 'package:foodapp/app_provider.dart';
import 'package:foodapp/routes/page_router.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  await Future.wait([
    TLocalStorage.init('food_app'),
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  ]);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterNativeSplash.remove();

  runApp(
    const AppProvider(child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NetworkStatusService().initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NetworkStatusService().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Connectivity().checkConnectivity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Food App',
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    theme: ThemeData(
  useMaterial3: true,
  primaryColor: Colors.white,
  fontFamily: "Quicksand",
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    surfaceTintColor: Colors.transparent,
  ),
  progressIndicatorTheme:  ProgressIndicatorThemeData(
    color: TColor.orange3
  ),
),

      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const NetworkStatusOverlay(),
          ],
        );
      },
    );
  }
}

