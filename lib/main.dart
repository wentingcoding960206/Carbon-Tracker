import 'package:carbon_tracer/home_page.dart';
import 'package:flutter/material.dart';
import 'login_chatpages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Tracer',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      // home: LoginChatpages(
      //   onTap: () {
      //     print("Sign up tapped!");
      //   },
      // ),
    );
  }
}