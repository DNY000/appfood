import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/core/services/connected_internet.dart';
import 'package:foodapp/viewmodels/banner_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

// App files
import 'package:foodapp/core/firebase_options.dart'
    if (kIsWeb) 'package:foodapp/core/firebase_web_options.dart';
import 'package:foodapp/data/repositories/food_repository.dart';
import 'package:foodapp/data/repositories/order_repository.dart';
import 'package:foodapp/data/repositories/restaurant_repository.dart';
import 'package:foodapp/data/repositories/user_repository.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:foodapp/viewmodels/simple_providers.dart';
import 'package:foodapp/routes/page_router.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Đặt màu chữ và icon của status bar thành màu đen
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
      options: kIsWeb
          ? FirebaseOptions(
              apiKey: dotenv.env["API_KEY"] ?? "",
              authDomain: "foodapp-daade.firebaseapp.com",
              projectId: "foodapp-daade",
              storageBucket: "foodapp-daade.appspot.com",
              messagingSenderId: "44206956684",
              appId: dotenv.env["APP_ID"] ?? "",
              measurementId: "G-ZCRF80FGZ6",
            )
          : DefaultFirebaseOptions.currentPlatform,
    ),
  ]);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodViewModel(FoodRepository())),
        ChangeNotifierProvider(
            create: (_) => RestaurantViewModel(RestaurantRepository())),
        ChangeNotifierProvider(
            create: (_) => OrderViewModel(OrderRepository(),
                foodRepository: FoodRepository())),
        ChangeNotifierProvider(create: (_) => UserViewModel(UserRepository())),
        ChangeNotifierProvider(create: (_) => BannerViewmodel()),
      ],
      child: const SimpleProviders(child: MyApp()),
    ),
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

    // Khởi tạo NetworkStatusService
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

class NetworkStatusOverlay extends StatefulWidget {
  const NetworkStatusOverlay({super.key});

  @override
  State<NetworkStatusOverlay> createState() => _NetworkStatusOverlayState();
}

class _NetworkStatusOverlayState extends State<NetworkStatusOverlay> {
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkStatusService().connectionState,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data! && !_isDialogShowing) {
          _isDialogShowing = true;
          Future.delayed(Duration.zero, () {
            if (mounted) {
              _showConnectionDialog();
            }
          });
        } else if (snapshot.hasData && snapshot.data! && _isDialogShowing) {
          _isDialogShowing = false;
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showConnectionDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isDialogShowing = false;
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      _isDialogShowing = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child:
                      const Icon(Icons.wifi_off, color: Colors.red, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mất kết nối',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Không thể kết nối đến máy chủ.\nVui lòng kiểm tra lại kết nối mạng của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          _isDialogShowing = false;
                          await NetworkStatusService().retryConnection();
                        },
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _isDialogShowing = false;
                          SystemNavigator.pop();
                        },
                        icon: const Icon(Icons.exit_to_app, size: 20),
                        label: const Text('Thoát'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
