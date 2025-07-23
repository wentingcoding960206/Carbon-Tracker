// import 'package:carbon_tracker/auth_gate.dart';
// import 'package:flutter/material.dart';
// import 'login_chatpages.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Carbon Tracker',
//       debugShowCheckedModeBanner: false,
//       home: AuthGate()
//       // home: LoginChatpages(
//       //   onTap: () {
//       //     print("Sign up tapped!");
//       //   },
//       // ),
//     );
//   }
// }




import 'package:carbon_tracker/auth_gate.dart';
import 'package:carbon_tracker/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(135, 158, 158, 158),
        ),
      ),
      home: AuthGate(),

      //home: ChatScreen()
    );
  }
}
