import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/event.dart';
import 'providers/event_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => EventProvider()..loadEvents(),
      child: MaterialApp(
        title: '日程管理',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
        ),
        home: HomeScreen(),
      ),
    ),
  );
}
