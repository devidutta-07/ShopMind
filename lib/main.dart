import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // MobileAds initialization disabled for fast startup
  // MobileAds.instance.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const SmartShoppingListApp(),
    ),
  );
}

class SmartShoppingListApp extends StatelessWidget {
  const SmartShoppingListApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium Palette (Requested)
    const appleGreen = Color(0xFF8DBF42); // Primary actions & buttons
    const brightRed = Color(0xFFFF4A4A); // Delete/logout actions
    const softBlue = Color(0xFF4A90E2); // Secondary actions & edits
    const goldenYellow = Color(0xFFFFC857); // Highlights & accents

    // Neumorphic Base Colors
    const backgroundDark = Color(0xFF1E1E1E); // Premium Dark Grey (Not Full Black)
    const surfaceDark = Color(0xFF2C2C2C); // Slightly lighter dark surface

    const textLight = Color(0xFFF5F5F5);

    return MaterialApp(
      title: 'ShopMind', 
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Permanent Dark Mode
      
      // LIGHT THEME (Disabled/Ignored essentially, but kept for structure)
      theme: ThemeData.dark(), 

      // DARK THEME (Premium Night)
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundDark,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleGreen,
          brightness: Brightness.dark,
          primary: appleGreen,
          secondary: softBlue,
          tertiary: goldenYellow,
          error: brightRed,
        ).copyWith(
          surface: surfaceDark,
          onSurface: textLight,
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundDark,
          foregroundColor: textLight,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: textLight,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: appleGreen, width: 2),
          ),
          prefixIconColor: appleGreen,
        ),
        
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appleGreen,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      
      home: const SplashScreen(),
    );
  }
}
