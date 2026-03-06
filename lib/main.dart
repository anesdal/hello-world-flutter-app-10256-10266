import 'package:flutter/material.dart';
import 'screens/manual_server_screen.dart'; // تأكد أن المسار صحيح لمجلد الـ Screens

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IPTV Player Pro',
      theme: ThemeData.dark(), // ثيم داكن مناسب لتطبيقات المشاهدة
      home: const ManualServerScreen(), // هذه هي الشاشة الأولى التي سيراها المستخدم
    );
  }
}
