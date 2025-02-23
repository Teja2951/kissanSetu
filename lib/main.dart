import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kisaansetu/farmer/farmerhome_screen.dart';
import 'package:kisaansetu/firebase_options.dart';
import 'package:kisaansetu/login_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await Supabase.initialize(url: 'https://nxcbzibngzutdvnlwado.supabase.co',
  //  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54Y2J6aWJuZ3p1dGR2bmx3YWRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyOTQ5MjEsImV4cCI6MjA1NDg3MDkyMX0.Dg-EF937zlJBDT6pQs7GrrBUitgk-L0imb4h7ybf7_8');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kissan Setu",
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (context, snapshot) {
        print("Auth State Changed: ${snapshot.connectionState}");
    print("Has Data: ${snapshot.hasData}");
    print("User: ${snapshot.data}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator())); 
        }
        if (snapshot.hasData && snapshot.data != null) {
          return FarmerHomeScreen(); 
        }
        return LoginScreen(); 
      },
    ),
    );
  }
}