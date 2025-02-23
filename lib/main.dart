import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kisaansetu/farmer/farmerhome_screen.dart';
import 'package:kisaansetu/firebase_options.dart';
import 'package:kisaansetu/login_screen.dart';
import 'package:kisaansetu/b_homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sp.Supabase.initialize(
    url: 'https://jjzprwdgnxohoycmwqnh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpqenByd2RnbnhvaG95Y213cW5oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAzMDExODUsImV4cCI6MjA1NTg3NzE4NX0.6lwPrcmkgvtbwkE34R-0z2HXRIATrEO7hkkJ3ab9sSw',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Fetches user role from Firestore and checks if the role list contains "buyer" or "farmer".
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (userDoc.exists) {
        String roles = userDoc["role"];
        print('The role is ${roles}');
        if (roles == 'Buyer') {
          print('buyer hai');
          return "buyer";
        } else if (roles.contains("Farmer")) {
          print('frame hai');
          return "farmer";
        }
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
    return null;
  }

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<String?>(
              future: getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                if (roleSnapshot.hasData) {
                  if (roleSnapshot.data == "buyer") {
                    return BuyerHomepage();
                  } else {
                    return FarmerHomeScreen();
                  }
                }
                print('confused');
                return LoginScreen(); // If role couldn't be determined
              },
            );
          }
          return LoginScreen();
        },
      ),
    );
  }
}
