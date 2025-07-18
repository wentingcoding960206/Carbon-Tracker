import 'dart:developer';

import 'package:carbon_tracker/auth_service.dart';
import 'package:carbon_tracker/forgot_password_page.dart';
import 'package:carbon_tracker/text_field.dart';
import 'package:flutter/material.dart';

class LoginChatpages extends StatelessWidget {
  LoginChatpages({
    super.key,
    required this.onTap,
  });
  
  final TextEditingController UsernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // tap to go to register page
  final void Function()? onTap;

  // login
  void login(BuildContext context) async {
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(UsernameController.text, passwordController.text);
    } catch (e) {
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(e.toString())
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/carbon-footprint.png',
                    height: 150,
                    width: 150,
                  ),
                ),
                const SizedBox(height: 16),

                // Login text field (Email)
                LoginScreenTextField(
                  textFieldLabel: 'Email',
                  textFieldController: UsernameController,
                  obscureText: false,
                ),
                const SizedBox(height: 20),

                // Login text field (Password)
                LoginScreenTextField(
                  textFieldLabel: 'Password',
                  textFieldController: passwordController,
                  obscureText: true,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        log('Forgot Password Button Pressed');
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return ForgotPasswordPage();
                          })
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                      ),
                      child: Text('Forgot Password ?'),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        onPressed: () {
                          login(context);
                          log('Login Button Pressed');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Login'),
                      ),
                    ),
                  ),
                ),
                
                const Expanded(child: SizedBox()),

                Padding(
                  padding: const EdgeInsets.only(bottom: 35, right: 50, left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?'),

                      SizedBox(width: 30,),

                      GestureDetector(
                        onTap: onTap, 
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blueAccent
                          ),
                        ),
                      )
                    ],
                  )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
