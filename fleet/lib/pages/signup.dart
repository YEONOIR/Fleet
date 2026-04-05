import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(172, 114, 161, 1.0),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color.fromRGBO(7, 14, 42, 1.0),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleSignUp() {
    if (_nameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // TODO: Collect user data and save to cloud storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cloud storage not connected yet'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Top glassmorphism card (form area)
                Positioned(
                  top: 30,
                  child: Hero(
                    tag: 'glass_form',
                    child: Material(
                      type: MaterialType.transparency,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            width: 330,
                            height: 660,
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
                  ),
                ),
                // Form content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      // Title
                      GradientText(
                        "Sign-up",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          fontFamily: "Poppins",
                          fontStyle: FontStyle.italic,
                        ),
                        colors: const [
                          Color.fromRGBO(172, 114, 161, 1.0),
                          Color.fromRGBO(7, 14, 42, 1.0),
                        ],
                        gradientDirection: GradientDirection.btt,
                      ),
                      const SizedBox(height: 8),
                      // Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person_outline_rounded,
                      ),
                      // Last Name
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                      ),
                      // Phone number
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone number',
                        keyboardType: TextInputType.phone,
                      ),
                      // ID card
                      _buildTextField(
                        controller: _idCardController,
                        label: 'ID card',
                        icon: Icons.badge_outlined,
                      ),
                      // Date of birth
                      TextField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: _selectDate,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Date of birth',
                          labelStyle: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month_rounded),
                            onPressed: _selectDate,
                          ),
                        ),
                      ),
                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      // Password
                      TextField(
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
                      // Address
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home_outlined,
                      ),
                      const SizedBox(height: 24),
                      // Sign-up button
                      SizedBox(
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
                            onPressed: _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Sign - up',
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
                      const SizedBox(height: 12),
                      // Already have account link
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Already have account?',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            color: Color.fromRGBO(7, 14, 42, 0.8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bottom logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            width: 280,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(217, 217, 217, 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Center(
                              child: Hero(
                                tag: 'app_logo',
                                child: Image(
                                  height: 180,
                                  width: 180,
                                  image: AssetImage("assets/icons/Logo.png"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 14,
      ),
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 14,
        ),
        suffixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}
