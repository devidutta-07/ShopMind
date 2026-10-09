import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';

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
    final appProvider = Provider.of<AppProvider>(context);

    // Accent Colors
    const appleGreen = Color(0xFF8DBF42); 
    const brightRed = Color(0xFFFF4A4A); 
    const softBlue = Color(0xFF4A90E2); 
    const goldenYellow = Color(0xFFFFC857); 

    // Theme Background Colors
    const lightBg = Color(0xFFCFCFCE); // Requested #CFCFCE
    const lightSurface = Color(0xFFE2E2E1);

    const darkBg = Color(0xFF18181A); // "Just black enough" dark grey
    const darkSurface = Color(0xFF242428);

    return MaterialApp(
      title: 'ShopMind', 
      debugShowCheckedModeBanner: false,
      themeMode: appProvider.themeMode, 
      
      // LIGHT THEME (#CFCFCE Background)
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: lightBg,
        cardColor: lightSurface,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleGreen,
          brightness: Brightness.light,
          primary: appleGreen,
          secondary: softBlue,
          tertiary: goldenYellow,
          error: brightRed,
        ).copyWith(
          surface: lightSurface,
          onSurface: const Color(0xFF18181A),
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBg,
          foregroundColor: Color(0xFF18181A),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF18181A),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurface,
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
          backgroundColor: const Color(0xFF18181A),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ), 

      // DARK THEME (#18181A "Just Black Enough" Background)
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBg,
        cardColor: darkSurface,
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: appleGreen,
          brightness: Brightness.dark,
          primary: appleGreen,
          secondary: softBlue,
          tertiary: goldenYellow,
          error: brightRed,
        ).copyWith(
          surface: darkSurface,
          onSurface: Colors.white,
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBg,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
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
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      
      home: appProvider.userProfile.isLoggedIn 
          ? const MainScreen() 
          : const LoginScreen(),
    );
  }
}
