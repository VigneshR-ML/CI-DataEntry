class Validator {
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  static String? validateTime(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    final regex = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
    if (!regex.hasMatch(value)) {
      return '$fieldName must be in HH:mm format (24-hour time)';
    }
    return null;
  }
}
