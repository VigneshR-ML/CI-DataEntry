import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceSuggestionField extends StatelessWidget {
  final TextEditingController controller;

  const PlaceSuggestionField({super.key, required this.controller});

  Future<List<String>> _getSuggestions(String search) async {
    final url = 'http://10.0.2.2:5000/places?query=$search';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List suggestions = json.decode(response.body);
      return suggestions.map<String>((s) => s.toString()).toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      itemBuilder: (context, suggestion) {
        return ListTile(title: Text(suggestion));
      },
      controller: TextEditingController(
        text: "Arival place",
      ),
      onSelected: (suggestion) {
        controller.text = suggestion;
      },
      suggestionsCallback: (pattern) async => await _getSuggestions(pattern),
    );
  }
}
