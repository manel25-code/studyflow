import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StudyFlow',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3576BC),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1E293B),
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
