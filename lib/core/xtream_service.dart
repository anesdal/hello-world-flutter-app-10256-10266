import 'dart:convert';
import 'package:http/http.dart' as http;

class XtreamService {
  static Future<Map<String, dynamic>?> login(String host, String user, String pass) async {
    final url = "$host/player_api.php?username=$user&password=$pass";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
