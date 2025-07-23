import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/mahasiswa_list.dart';
import 'screens/mahasiswa_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SimaApp());
}

class SimaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/mahasiswa-list': (context) => MahasiswaListScreen(),
        '/mahasiswa-form': (context) => MahasiswaFormScreen(),
      },
    );
  }
}
