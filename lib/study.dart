import 'package:flutter/material.dart';
//import 'package:test/pages/Mpage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/settings.dart';
//import 'package:test/timelineui.dart';
//import 'package:test/timelineui.dart';
//import './pages/Mpage.dart'
//import 'package:flutter/cupertino.dart';
/*void main(){
  runApp(const MyApp());
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_TW');

  runApp(MyApp());
}

// Widgets
// 1. StatelessWidget
//2. StatefulWidget

//State 

//1. Material Design for google
//2. Cupertino Design foe apple

/*class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('zh', 'TW'),
      supportedLocales: [Locale('zh', 'TW')],
      //localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: TimelineUI(),
    );
  }
}*/

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    
    /*return Text( //return const Text();
      "Hello, World",
      textDirection: TextDirection.ltr,
      );*/
    return MaterialApp(
      home: SettingsPage(),
    );
    
  }
}


