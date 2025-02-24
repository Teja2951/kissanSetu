import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kisaansetu/auth/auth_service.dart';
import 'package:kisaansetu/auth/login_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _userType = 'Farmer'; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  // child: ClipRRect(
                  //   borderRadius: BorderRadius.circular(40),
                  //   child: Image.asset('assets/images/img11.png'),
                  // ),
                ),
                Spacer(),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign up',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),
            
                        // Name Field
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            hintText: "Enter Full Name",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                          ),
                        ),
                        const SizedBox(height: 20),
            
                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.alternate_email),
                            hintText: "Enter Email ID",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                          ),
                        ),
                        const SizedBox(height: 20),
            
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            hintText: "Enter Password",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                          ),
                        ),
                        const SizedBox(height: 20),
            
                        // User Type Selection (Radio Buttons)
                        const Text(
                          "Please Select your choice",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
            setState(() {
              _userType = 'Farmer';
            });
                    },
                    child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _userType == 'Farmer' ? Colors.amber : Colors.white,
              border: Border.all(color: Colors.amber),
            ),
            child: Center(
              child: Text(
                'Farmer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _userType == 'Farmer' ? Colors.white : Colors.black,
                ),
              ),
            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
            setState(() {
              _userType = 'Buyer';
            });
                    },
                    child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _userType == 'Buyer' ? Colors.amber : Colors.white,
              border: Border.all(color: Colors.amber),
            ),
            child: Center(
              child: Text(
                'Buyer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _userType == 'Buyer' ? Colors.white : Colors.black,
                ),
              ),
            ),
                    ),
                  ),
                ),
              ],
            ),
                        
                        const SizedBox(height: 30),
            
                        // Sign Up Button
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              AuthService().signUpWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                                name: _nameController.text,
                                role: _userType,
                                context: context,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            ),
                            child: const Text('Sign Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 20),
            
                        const Divider(),
            
                        // Sign In Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginScreen())
                                );
                              },
                              child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
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
