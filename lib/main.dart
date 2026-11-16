import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'services/money_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MoneyService.init(); // open the database before the app starts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Money',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HomePage(),
    );
  }
}