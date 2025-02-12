



import 'package:connectmarian/Loginpage.dart';
import 'package:connectmarian/Registrationpage.dart';
import 'package:connectmarian/adlogin.dart';
import 'package:connectmarian/adm.dart';
import 'package:connectmarian/admin.dart';
import 'package:connectmarian/advertise.dart';
import 'package:connectmarian/dashboard.dart';
import 'package:connectmarian/donate.dart';
import 'package:connectmarian/firebase_options.dart';
import 'package:connectmarian/home_screen.dart';
import 'package:connectmarian/imagepicker.dart';


import 'package:connectmarian/lostfound.dart';
import 'package:connectmarian/myads.dart';
import 'package:connectmarian/sell.dart';
import 'package:connectmarian/video.dart';
import 'package:connectmarian/wisheg.dart';


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:Loginpage(title: 'TS'),
    );
  }
} 


