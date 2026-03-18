import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    // TODO: Connect to cloud authentication
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Cloud authentication not connected yet'),
    //   ),
    // );
    // For now, accept any credentials for prototype testing
    Navigator.pushReplacementNamed(context, '/renter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.fromRGBO(172, 114, 161, 1.0),
              Color.fromRGBO(251, 217, 250, 1.0),
              Color.fromRGBO(7, 14, 42, 1.0),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glassmorphism card
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.22,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: 330,
                        height: 480,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(217, 217, 217, 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Logo
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.1,
                  child: const Image(
                    height: 300,
                    width: 300,
                    image: AssetImage("assets/icons/Logo.png"),
                  ),
                ),
                // Login form
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.42,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Title
                      GradientText(
                        "Login",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          fontFamily: "Poppins",
                        ),
                        colors: const [
                          Color.fromRGBO(172, 114, 161, 1.0),
                          Color.fromRGBO(7, 14, 42, 1.0),
                        ],
                        gradientDirection: GradientDirection.btt,
                      ),
                      const SizedBox(height: 16),
                      // Email field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                            ),
                            suffixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Password field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.lock_outline_rounded
                                    : Icons.lock_open_rounded,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Login button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(172, 114, 161, 1.0),
                                  Color.fromRGBO(7, 14, 42, 1.0),
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Create an account link
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          'Create an account',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            color: Color.fromRGBO(7, 14, 42, 0.8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
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