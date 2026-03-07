import 'package:flutter/material.dart';
import '../core/xtream_service.dart';
import 'xtream_categories_screen.dart';

class ManualServerScreen extends StatefulWidget {
  @override
  _ManualServerScreenState createState() => _ManualServerScreenState();
}

class _ManualServerScreenState extends State<ManualServerScreen> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> _login() async {
    final data = await XtreamService.login(
      _hostController.text, 
      _userController.text, 
      _passController.text
    );
    
    if (data != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => XtreamCategoriesScreen(host: _hostController.text)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(controller: _hostController, decoration: InputDecoration(labelText: 'Host')),
          TextField(controller: _userController, decoration: InputDecoration(labelText: 'User')),
          TextField(controller: _passController, decoration: InputDecoration(labelText: 'Password')),
          ElevatedButton(onPressed: _login, child: Text("Login"))
        ],
      ),
    );
  }
}
