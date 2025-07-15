import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:neffils/presentation/screens/application_portal/industry_management/view_Industry_management_screen.dart';
import 'package:neffils/ui/theme_manager.dart';
import 'package:neffils/utils/colors/color.dart';
import 'package:neffils/utils/materialcolor.dart';
import 'package:provider/provider.dart';
import 'data/providers/auth_providers.dart';
import 'presentation/screens/home_screen/home_navbar_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize(); // Load saved tokens & user data
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver], // Required for RouteObserver
      theme: getApplicationTheme(),
      home: _isLoading
          ? const LoadingScreen()
          : authProvider.isAuthenticated
              ? HomeNavbarScreen(username: authProvider.currentUser!.username)
              : const LoginScreen(),

      builder: (context, child) => _Unfocus(child: child!),
    );
  }
}

class _Unfocus extends StatelessWidget {
  const _Unfocus({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (() => FocusManager.instance.primaryFocus?.unfocus()),
        child: child,
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
