import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:kisaansetu/Farmers/farmerhome_screen.dart';
import 'package:kisaansetu/firebase_options.dart';
import 'package:kisaansetu/auth/login_screen.dart';
import 'package:kisaansetu/b_homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sp.Supabase.initialize(
    url: 'qnh.supabase.co',
    anonKey:
        'hehe hehe hehe',
  );

  Gemini.init(
    apiKey: 'heheheh',
  );
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    return LayoutBuilder(

      builder: (BuildContext,Constraints){

      if(Constraints.maxWidth>600) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
          ),
          home: Center(child: Text('Please switch to mobile view or resize the window we are currently not supporting web view',style: TextStyle(
          color: Colors.black,
          fontSize: 24,
        ),)));
      }
      else{
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Kissan Setu",
        theme:  ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
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
                  return FarmerHomeScreen(); // If role couldn't be determined
                },
              );
            }
            return LoginScreen();
          },
        ),
      );
      }
      }
    );
  }
}
