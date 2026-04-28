import 'package:flutter/material.dart';

import '../theme/ryadom_theme.dart';
import '../features/home/presentation/home_screen.dart';

class RyadomApp extends StatelessWidget {
  const RyadomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ryadom',
      debugShowCheckedModeBanner: false,
      theme: buildRyadomTheme(),
      home: const HomeScreen(),
    );
  }
}
