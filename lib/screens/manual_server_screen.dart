import 'package:flutter/material.dart';
import 'xtream_categories_screen.dart';
import '../core/xtream_service.dart';

class ManualServerScreen extends StatefulWidget {
  const ManualServerScreen({super.key});
  @override
  State<ManualServerScreen> createState() => _ManualServerScreenState();
}

class _ManualServerScreenState extends State<ManualServerScreen> {
  final _host = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  void _loginXtream() async {
    if (_host.text.isEmpty || _user.text.isEmpty || _pass.text.isEmpty) return;
    setState(() => _loading = true);
    
    final data = await XtreamService.login(_host.text, _user.text, _pass.text);
    setState(() => _loading = false);

    if (data != null && data['user_info']['auth'] == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => 
        XtreamCategoriesScreen(host: _host.text, user: _user.text, pass: _pass.text)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ في البيانات')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة سيرفر')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Xtream Codes API", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _host, decoration: const InputDecoration(labelText: 'Host (http://example.com:8080)')),
          TextField(controller: _user, decoration: const InputDecoration(labelText: 'Username')),
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 20),
          _loading 
            ? const Center(child: CircularProgressIndicator()) 
            : ElevatedButton(onPressed: _loginXtream, child: const Text('دخول')),
        ],
      ),
    );
  }
}

