// lib/features/customer/screens/add_request_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/feedback_utils.dart';
import '../../../core/data/locations_data.dart';
import '../models/request_model.dart';
import '../providers/request_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'matching_gp_screen.dart';

class AddRequestScreen extends StatefulWidget {
  const AddRequestScreen({Key? key}) : super(key: key);

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _packageType;
  final _weightController = TextEditingController();
  String? _departureCountry;
  String? _departureCity;
  String? _arrivalCountry;
  String? _arrivalCity;
  DateTime? _earliestDepartureTime;
  DateTime? _latestArrivalTime;
  bool _isFragile = false;
  bool _isLoading = false;

  final List<String> _packageTypes = [
    'Documents',
    'Electronics',
    'Clothing',
    'Food',
    'Other'
  ];

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Widget _buildLocationDropdowns() {
    return Column(
      children: [
        _buildDropdown(
          label: 'Pays de départ',
          value: _departureCountry,
          items: LocationData.getCountries(),
          onChanged: (value) {
            setState(() {
              _departureCountry = value;
              _departureCity = null;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Ville de départ',
          value: _departureCity,
          items: _departureCountry != null
              ? LocationData.getCitiesForCountry(_departureCountry!)
              : [],
          onChanged: (value) => setState(() => _departureCity = value),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Pays d\'arrivée',
          value: _arrivalCountry,
          items: LocationData.getCountries(),
          onChanged: (value) {
            setState(() {
              _arrivalCountry = value;
              _arrivalCity = null;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Ville d\'arrivée',
          value: _arrivalCity,
          items: _arrivalCountry != null
              ? LocationData.getCitiesForCountry(_arrivalCountry!)
              : [],
          onChanged: (value) => setState(() => _arrivalCity = value),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(bool isEarliestDeparture) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryBlue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isEarliestDeparture) {
            _earliestDepartureTime = dateTime;
          } else {
            _latestArrivalTime = dateTime;
          }
        });
      }
    }
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
              : 'Select Date and Time',
        ),
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      children: [
        _buildDateTimePicker(
          label: 'Heure de départ la plus tôt',
          value: _earliestDepartureTime,
          onTap: () => _selectDateTime(true),
        ),
        const SizedBox(height: 16),
        _buildDateTimePicker(
          label: 'Latest Arrival Time',
          value: _latestArrivalTime,
          onTap: () => _selectDateTime(false),
        ),
      ],
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_earliestDepartureTime == null || _latestArrivalTime == null) {
      FeedbackUtils.showErrorSnackBar(
        context,
        'Please select both departure and arrival times',
      );
      return;
    }

    setState(() => _isLoading = true);

    DocumentReference? docRef;

    try {
      print('Submitting request with data:');
      print('Package Type: $_packageType');
      print('Weight: ${_weightController.text}');
      print('Departure: $_departureCountry, $_departureCity');
      print('Arrival: $_arrivalCountry, $_arrivalCity');

      docRef = await context.read<RequestProvider>().submitRequest(
        packageType: _packageType!,
        weight: double.parse(_weightController.text),
        departureCountry: _departureCountry!,
        departureCity: _departureCity!,
        arrivalCountry: _arrivalCountry!,
        arrivalCity: _arrivalCity!,
        earliestDepartureTime: _earliestDepartureTime!,
        latestArrivalTime: _latestArrivalTime!,
        isFragile: _isFragile,
      );

      if (docRef != null && mounted) {
        print('Request submitted successfully, fetching latest request...');

        // Fetch the document using the docRef ID
        final docSnapshot = await FirebaseFirestore.instance
            .collection('requests')
            .doc(docRef.id)
            .get();

        print('Fetched request data: ${docSnapshot.data()}');
        print('Request ID: ${docSnapshot.id}');

        final requestData = docSnapshot.data();
        final requestId = docSnapshot.id;

        if (requestData != null && mounted) {
          final request = RequestModel.fromMap(requestData, requestId);

          FeedbackUtils.showSuccessSnackBar(
            context,
            'Request submitted successfully!',
          );

          if (requestData != null && mounted) {
            final request = RequestModel.fromMap(requestData, requestId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchingGPsScreen(request: request),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error in request submission: $e');
      if (mounted) {
        FeedbackUtils.showErrorSnackBar(
          context,
          'Error: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Ajouter une demande',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Entrez les détails de votre colis, puis demandez au GP le mieux adapté à transporter votre colis:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            _buildDropdown(
              label: 'Type de colis',
              value: _packageType,
              items: _packageTypes,
              onChanged: (value) => setState(() => _packageType = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Poids du colis',
                suffix: Text('KG'),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the weight';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLocationDropdowns(),
            const SizedBox(height: 16),
            _buildDateTimePickers(),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Le colis est-il fragile ?'),
              value: _isFragile,
              onChanged: (value) => setState(() => _isFragile = value),
              activeColor: AppColors.primaryBlue,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Demander',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}