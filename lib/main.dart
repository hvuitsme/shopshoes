import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shopshoes/pages/home.dart';
import 'package:shopshoes/pages/bottomnav.dart';
import 'package:shopshoes/pages/product_detail.dart';
import 'package:shopshoes/pages/login.dart';
import 'package:shopshoes/pages/signup.dart';
import 'package:shopshoes/admin/admin_login.dart';
import 'package:shopshoes/admin/home_admin.dart';
import 'package:shopshoes/admin/add_product.dart';
import 'package:shopshoes/services/constrant.dart';
import 'package:shopshoes/admin/all_orders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = publishableKey;
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyCLuFt4ffzlgjv5vpylXZeFEQ4Wvw9Ph08',
    appId: '1:1054868345099:android:59a583ec108e849ea3d20e',
    messagingSenderId: '1054868345099',
    projectId: 'shopshoes-72274',
    storageBucket: 'shopshoes-72274.appspot.com',
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const BottomNav(),
    );
  }
}
