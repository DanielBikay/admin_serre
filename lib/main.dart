//main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pages/home_page.dart';
import 'utils/theme.dart';
import 'pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configuration de la persistence
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  
  runApp(SerreApp());
}

class SerreApp extends StatefulWidget {
 const SerreApp({super.key});

  @override
  State<SerreApp> createState() => _SerreAppState();
}

class _SerreAppState extends State<SerreApp> {
  int _selectedThemeIndex = 0;

  void _changeTheme(int index) {
    setState(() {
      _selectedThemeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serre Intelligente',
      theme: AppThemes.themes[_selectedThemeIndex],
      home: AuthChecker(
        onChangeTheme: _changeTheme,
        currentThemeIndex: _selectedThemeIndex,
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  final Function(int) onChangeTheme;
  final int currentThemeIndex;

  const AuthChecker({
  required this.onChangeTheme,
  required this.currentThemeIndex,
  super.key, // Correction ici
});


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomePage(
            onChangeTheme: onChangeTheme,
            currentThemeIndex: currentThemeIndex,
          );
        } else {
          return LoginPage();
        }
      },
    );
  }
}