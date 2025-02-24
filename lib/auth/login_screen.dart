import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kisaansetu/auth/auth_service.dart';
import 'package:kisaansetu/auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade200,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 50),
                Placeholder(fallbackHeight: 200,fallbackWidth: double.infinity,),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(40),
                //   child: //Image.asset('assets/images/img11.png', width: 150, height: 150),
                // ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Log In',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                
                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email, color: Colors.black),
                          hintText: "Enter Email ID",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 20),
                
                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Colors.black),
                          hintText: "Enter Password",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                
                      // Login Button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            AuthService().logInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text, 
                              context: context
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                          ),
                          child: const Text('Log in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(thickness: 1, color: Colors.grey.shade400)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("or"),
                          ),
                          Expanded(child: Divider(thickness: 1, color: Colors.grey.shade400)),
                        ],
                      ),
                      const SizedBox(height: 20),
                
                      // Sign Up Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?", style: TextStyle(fontSize: 16)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupPage(),
                                )
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
