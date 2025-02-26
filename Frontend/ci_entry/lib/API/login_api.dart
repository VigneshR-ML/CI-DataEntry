import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginApi {
  final String baseURL = "http://10.0.2.2:5000";

  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseURL/login");

    try{
      final response = await http.post(
        url,
        headers : {"Content-Type" : "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Login failed"};
      }
    }
    catch (e) {
      return {"error": "Server error: $e"};
    }
  }
}
