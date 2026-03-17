// Noey will do this page go do other

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.fromRGBO(172, 114, 161, 1.0),
              Color.fromRGBO(251, 217, 250, 1.0),
              Color.fromRGBO(7, 14, 42, 1.0),
            ]
          )
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  width: 330,
                  height: 560,
                  margin: EdgeInsets.fromLTRB(0, 170, 0, 0),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(217, 217, 217, 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3), // เส้นขอบสีขาวจางๆ ให้ดูเป็นกระจก
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              
              child: Image(
                height: 350,
                width: 350,
                image: AssetImage("assets/icons/Logo.png")
              ),
            ),
            Positioned(
              top: 450,
              child: Column(
                children: [
                  GradientText(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      fontFamily: "Poppins"
                    ),
                    colors: [
                    Color.fromRGBO(172, 114, 161, 1.0),
                    Color.fromRGBO(7, 14, 42, 1.0),
                    ],
                    gradientDirection: GradientDirection.btt,
                  ),
                  _loginInput(),
                ],
              ),
            )
          ],
        )   
      ),
    );
  }

  Widget _loginInput(){
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Email'
                ),
              ),
            ),
            // Icon(
            //   Icons.mail_outline_rounded,
            // ),
          ],
        )
      ],
    );
  }
}