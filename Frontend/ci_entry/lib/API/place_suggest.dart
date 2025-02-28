import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ci_entry/API/validator.dart';

class PlaceSuggestionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isTimeField;

  const PlaceSuggestionField({
    super.key, 
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isTimeField = false,
  });

  Future<List<String>> _getSuggestions(String search) async {
    final url = 'http://172.20.10.7:5000/places?query=$search';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> suggestions = json.decode(response.body);
      return suggestions.map<String>((s) => s.toString()).toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textFieldController = TextEditingController();
    
    // Set the initial value based on the controller if it exists
    if (controller.text.isNotEmpty) {
      textFieldController.text = controller.text;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TypeAheadField<String>(
        builder: (context, tController, focusNode) {
          // Use the local controller instead of the one provided by TypeAheadField
          return TextFormField(
            controller: textFieldController,
            focusNode: focusNode,
            autofocus: true,
            validator: validator,
            keyboardType: keyboardType,
            // Add input formatters to automatically format text to uppercase
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                return TextEditingValue(
                  text: newValue.text.toUpperCase(),
                  selection: newValue.selection,
                );
              }),
            ],
            // Update the main controller when text changes
            onChanged: (value) {
              tController.text = value;
            },
            decoration: InputDecoration(
              labelText: label,
              floatingLabelStyle: const TextStyle(
                color: Color.fromARGB(255, 62, 122, 76),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 62, 122, 76),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 62, 122, 76),
                ),
              ),
              contentPadding: const EdgeInsets.all(12.0),
              suffixIcon:
                isTimeField
                  ? const Icon(
                      Icons.access_time,
                      color: Color.fromARGB(255, 62, 122, 76),
                    )
                  : null,
            ),
          );
        },
        itemBuilder: (context, suggestion) {
          return ListTile(title: Text(suggestion));
        },
        onSelected: (suggestion) {
          // Update both controllers with the selected place name
          textFieldController.text = suggestion;
          controller.text = suggestion;
        },
        suggestionsCallback: (pattern) async {
          if (pattern.length >= 2) { // Only fetch suggestions if at least 2 characters
            // Convert pattern to uppercase before querying
            return await _getSuggestions(pattern.toUpperCase());
          }
          return [];
        },
      ),
    );
  }
}