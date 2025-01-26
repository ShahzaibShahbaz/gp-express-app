import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/data/locations_data.dart';
import '../../../core/utils/feedback_utils.dart';
import '../../../core/constants/color_constants.dart';
import '../../auth/providers/auth_provider.dart';

import 'package:flutter/material.dart';

import '../models/mission_model.dart';


class AddMissionScreen extends StatefulWidget {
  const AddMissionScreen({Key? key}) : super(key: key);

  @override
  State<AddMissionScreen> createState() => _AddMissionScreenState();
}

class _AddMissionScreenState extends State<AddMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _departureCountry;
  String? _departureCity;
  String? _departureAirport;
  String? _arrivalCountry;
  String? _arrivalCity;
  String? _arrivalAirport;
  DateTime? _departureTime;
  DateTime? _arrivalTime;
  final _capacityController = TextEditingController();
  bool _hasFlightTicket = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isDeparture) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          final DateTime combinedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isDeparture) {
            _departureTime = combinedDateTime;
          } else {
            _arrivalTime = combinedDateTime;
          }
        });
      }
    }
  }

  Future<void> _submitMission() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departureTime == null || _arrivalTime == null) {
      FeedbackUtils.showErrorSnackBar(
        context,
        'Please select both departure and arrival times',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final mission = MissionModel(
        id: '', // Firestore will generate this
        gpId: context.read<AuthProvider>().user!.uid,
        departureCountry: _departureCountry!,
        departureCity: _departureCity!,
        departureAirport: _departureAirport!,
        arrivalCountry: _arrivalCountry!,
        arrivalCity: _arrivalCity!,
        arrivalAirport: _arrivalAirport!,
        departureTime: _departureTime!,
        arrivalTime: _arrivalTime!,
        capacity: int.parse(_capacityController.text),
        hasFlightTicket: _hasFlightTicket,
        status: MissionStatus.pending,
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('missions')
          .add(mission.toMap());
      if (mounted) {
        FeedbackUtils.showSuccessSnackBar(
          context,
          'Mission added successfully!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        FeedbackUtils.showErrorSnackBar(
          context,
          'Error adding mission: $e',
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ajouter une mission',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrez les détails de votre vol et nous vous aiderons à trouver les biens les plus adaptés à transporter avec vous.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Pays de départ',
                value: _departureCountry,
                items: LocationData.getCountries(),
                onChanged: (value) {
                  setState(() {
                    _departureCountry = value;
                    _departureCity = null;
                    _departureAirport = null;
                  });
                },
              ),
              _buildDropdown(
                label: 'Ville de départ',
                value: _departureCity,
                items: _departureCountry != null
                    ? LocationData.getCitiesForCountry(_departureCountry!)
                    : [],
                onChanged: (value) {
                  setState(() {
                    _departureCity = value;
                    _departureAirport = null;
                  });
                },
              ),
              _buildDropdown(
                label: 'Aéroport de départ',
                value: _departureAirport,
                items: (_departureCountry != null && _departureCity != null)
                    ? LocationData.getAirportsForCity(
                  _departureCountry!,
                  _departureCity!,
                )
                    : [],
                onChanged: (value) => setState(() => _departureAirport = value),
              ),
              _buildDropdown(
                label: 'Pays d\'arrivée',
                value: _arrivalCountry,
                items: LocationData.getCountries(),
                onChanged: (value) {
                  setState(() {
                    _arrivalCountry = value;
                    _arrivalCity = null;
                    _arrivalAirport = null;
                  });
                },
              ),
              _buildDropdown(
                label: 'Ville d\'arrivée',
                value: _arrivalCity,
                items: _arrivalCountry != null
                    ? LocationData.getCitiesForCountry(_arrivalCountry!)
                    : [],
                onChanged: (value) {
                  setState(() {
                    _arrivalCity = value;
                    _arrivalAirport = null;
                  });
                },
              ),
              _buildDropdown(
                label: 'Aéroport d\'arrivée',
                value: _arrivalAirport,
                items: (_arrivalCountry != null && _arrivalCity != null)
                    ? LocationData.getAirportsForCity(
                  _arrivalCountry!,
                  _arrivalCity!,
                )
                    : [],
                onChanged: (value) => setState(() => _arrivalAirport = value),
              ),
              const SizedBox(height: 16),
              _buildDateTimePicker(
                label: 'Heure de départ',
                value: _departureTime,
                onTap: () => _selectDateTime(true),
              ),
              _buildDateTimePicker(
                label: 'Heure d\'arrivée',
                value: _arrivalTime,
                onTap: () => _selectDateTime(false),
              ),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacité de charge (en KG)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _hasFlightTicket,
                onChanged: (value) => setState(() => _hasFlightTicket = value!),
                title: const Text('Billet d\'avion'),
                controlAffinity: ListTileControlAffinity.leading  ,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Demander'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
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
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Text(
            value != null
                ? '${value.day}/${value.month}/${value.year} ${value.hour}:${value.minute.toString().padLeft(2, '0')}'
                : 'Select Date and Time',
          ),
        ),
      ),
    );
  }
}