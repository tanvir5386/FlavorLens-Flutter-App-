import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash.dart';
import 'screens/home.dart';
import 'screens/planner.dart';
import 'screens/profile.dart';
import 'screens/about.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'FlavorLens',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        initialRoute: '/home',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/planner': (context) => const PlannerScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/about': (context) => const AboutScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Simple app state provider
class AppState extends ChangeNotifier {
  int _recipeCount = 0;

  int get recipeCount => _recipeCount;

  void incrementRecipeCount() {
    _recipeCount++;
    notifyListeners();
  }
}
