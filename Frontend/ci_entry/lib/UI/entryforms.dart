import 'package:ci_entry/API/place_suggest.dart';
import 'package:flutter/material.dart';
import 'package:ci_entry/API/data_handling.dart';
import 'package:ci_entry/API/validator.dart';

class BusEntryForm extends StatefulWidget {
  final int userId;
  const BusEntryForm({super.key, required this.userId});

  @override
  State<BusEntryForm> createState() => _BusEntryFormState();
}

class _BusEntryFormState extends State<BusEntryForm> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _busNoController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  final TextEditingController _arrivalPlaceController = TextEditingController();
  final TextEditingController _departurePlaceController =
      TextEditingController();
  final TextEditingController _checkingPlaceController =
      TextEditingController();
  final TextEditingController _checkingTimeController = TextEditingController();
  final TextEditingController _totalPassengersController =
      TextEditingController();
  final TextEditingController _freePassengersController =
      TextEditingController();
  final TextEditingController _afterCheckingPlaceController =
      TextEditingController();
  final TextEditingController _afterCheckingTimeController =
      TextEditingController();
  final TextEditingController _caseDetailsController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _busNoController.dispose();
    _arrivalTimeController.dispose();
    _arrivalPlaceController.dispose();
    _departurePlaceController.dispose();
    _checkingPlaceController.dispose();
    _checkingTimeController.dispose();
    _totalPassengersController.dispose();
    _freePassengersController.dispose();
    _afterCheckingPlaceController.dispose();
    _afterCheckingTimeController.dispose();
    _caseDetailsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
    });

    Map<String, dynamic> data = {
      "user_id": widget.userId,
      "bus_no": int.parse(_busNoController.text),
      "arrival_time": _arrivalTimeController.text,
      "arrival_place": _arrivalPlaceController.text,
      "departure_place": _departurePlaceController.text,
      "checking_place": _checkingPlaceController.text,
      "checking_time": _checkingTimeController.text,
      "total_passengers": int.parse(_totalPassengersController.text),
      "free_passengers": int.parse(_freePassengersController.text),
      "after_checking_place": _afterCheckingPlaceController.text,
      "after_checking_time": _afterCheckingTimeController.text,
      "case_details": _caseDetailsController.text,
    };

    try {
      final result = await DataHandling.submitData(data);
      if (result['success']) {
        showDialog(
          barrierColor: Color.fromARGB(255, 237, 255, 241),
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Data Entered Successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _busNoController.clear();
                    _arrivalTimeController.clear();
                    _arrivalPlaceController.clear();
                    _departurePlaceController.clear();
                    _checkingPlaceController.clear();
                    _checkingTimeController.clear();
                    _totalPassengersController.clear();
                    _freePassengersController.clear();
                    _afterCheckingPlaceController.clear();
                    _afterCheckingTimeController.clear();
                    _caseDetailsController.clear();
                  },
                  child: const Text('OK', style: TextStyle(
                    color: Color.fromARGB(255, 62, 122, 76)
                  ),),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${result['message']}')));
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error occurred: $error')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String formatTimeOfDay24(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(
                255,
                62,
                122,
                76,
              ), 
              onPrimary: Colors.white, 
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: const Color.fromARGB(255, 62, 122, 76),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = formatTimeOfDay24(picked);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isTimeField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
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
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        readOnly: isTimeField,
        onTap: isTimeField ? () => _selectTime(context, controller) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bus Management Entry',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 62, 122, 76),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'User ID: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.userId.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _busNoController,
                    label: 'Bus Number',
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            Validator.validateInteger(value, 'Bus Number'),
                  ),
                  _buildTextField(
                    controller: _arrivalTimeController,
                    label: 'Arrival Time (HH:mm)',
                    keyboardType: TextInputType.datetime,
                    validator:
                        (value) =>
                            Validator.validateTime(value, 'Arrival Time'),
                    isTimeField: true,
                  ),
                  PlaceSuggestionField(controller: _arrivalPlaceController),
                  _buildTextField(
                    controller: _arrivalPlaceController,
                    label: 'Arrival Place',
                    validator:
                        (value) =>
                            Validator.validateNotEmpty(value, 'Arrival Place'),
                  ),
                  _buildTextField(
                    controller: _departurePlaceController,
                    label: 'Departure Place',
                    validator:
                        (value) => Validator.validateNotEmpty(
                          value,
                          'Departure Place',
                        ),
                  ),
                  _buildTextField(
                    controller: _checkingPlaceController,
                    label: 'Checking Place',
                    validator:
                        (value) =>
                            Validator.validateNotEmpty(value, 'Checking Place'),
                  ),
                  _buildTextField(
                    controller: _checkingTimeController,
                    label: 'Checking Time (HH:mm)',
                    keyboardType: TextInputType.datetime,
                    validator:
                        (value) =>
                            Validator.validateTime(value, 'Checking Time'),
                    isTimeField: true,
                  ),
                  _buildTextField(
                    controller: _totalPassengersController,
                    label: 'Total Passengers',
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => Validator.validateInteger(
                          value,
                          'Total Passengers',
                        ),
                  ),
                  _buildTextField(
                    controller: _freePassengersController,
                    label: 'Free Passengers',
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            Validator.validateInteger(value, 'Free Passengers'),
                  ),
                  _buildTextField(
                    controller: _afterCheckingPlaceController,
                    label: 'After Checking Place',
                    validator:
                        (value) => Validator.validateNotEmpty(
                          value,
                          'After Checking Place',
                        ),
                  ),
                  _buildTextField(
                    controller: _afterCheckingTimeController,
                    label: 'After Checking Time (HH:mm)',
                    keyboardType: TextInputType.datetime,
                    validator:
                        (value) => Validator.validateTime(
                          value,
                          'After Checking Time',
                        ),
                    isTimeField: true,
                  ),
                  _buildTextField(
                    controller: _caseDetailsController,
                    label: 'Case Details',
                    maxLines: 3,
                    validator:
                        (value) =>
                            Validator.validateNotEmpty(value, 'Case Details'),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 62, 122, 76),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                      child:
                          _isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
