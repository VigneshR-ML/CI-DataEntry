import 'dart:convert';
import 'package:http/http.dart' as http;

class DataHandling {
  static Future<Map<String, dynamic>> submitData(Map<String, dynamic> data) async {
    final url = Uri.parse('http://172.20.10.7:5000/data-entry'); 
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    
    if (response.statusCode == 201) {
      return {"success": true, "message": "Data entry added successfully"};
    } else {
      return {"success": false, "message": response.body};
    }
  }
}
