import 'package:flutter/material.dart';
import 'package:iqaama_app/screens/map_circle_screen.dart';

import 'package:iqaama_app/screens/property_map_list.dart';
import 'package:iqaama_app/screens/radius_selector_screen.dart.dart';

  

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Iqaama App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      home: const RadiusSelectorScreen(),


      routes: {
        '/radius': (context) => const RadiusSelectorScreen(),
      
      },
    );
  }
}
