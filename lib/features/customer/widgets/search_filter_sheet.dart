// lib/features/customer/widgets/search_filter_sheet.dart

import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/data/locations_data.dart';

class SearchFilterSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const SearchFilterSheet({
    Key? key,
    this.initialFilters = const {},
  }) : super(key: key);

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late String? _departureCity;
  late String? _arrivalCity;
  late DateTime? _departureTime;
  late DateTime? _arrivalTime;
  final TextEditingController _capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _departureCity = widget.initialFilters['departureCity'];
    _arrivalCity = widget.initialFilters['arrivalCity'];
    _departureTime = widget.initialFilters['departureTime'];
    _arrivalTime = widget.initialFilters['arrivalTime'];
    _capacityController.text = widget.initialFilters['minCapacity']?.toString() ?? '';
  }

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryBlue,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
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

  void _applyFilters() {
    Navigator.pop(context, {
      'departureCity': _departureCity,
      'arrivalCity': _arrivalCity,
      'departureTime': _departureTime,
      'arrivalTime': _arrivalTime,
      'minCapacity': _capacityController.text.isNotEmpty
          ? int.tryParse(_capacityController.text)
          : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCityDropdown(
                      label: 'Départ',
                      value: _departureCity,
                      onChanged: (value) => setState(() => _departureCity = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCityDropdown(
                      label: 'Arrivée',
                      value: _arrivalCity,
                      onChanged: (value) => setState(() => _arrivalCity = value),
                    ),
                  ),
                ],
              ),
            ),
            _buildDateTimePicker(
              label: 'Heure de départ',
              value: _departureTime,
              onTap: () => _selectDateTime(true),
            ),
            _buildDateTimePicker(
              label: "Heure d'arrivée",
              value: _arrivalTime,
              onTap: () => _selectDateTime(false),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacité minimale de transport',
                  border: OutlineInputBorder(),
                  suffixText: 'KG',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () {
                  // Reset the form
                  setState(() {
                    _departureCity = null;
                    _arrivalCity = null;
                    _departureTime = null;
                    _arrivalTime = null;
                    _capacityController.clear();
                  });
                },
                child: const Text('Réinitialiser les filtres'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Rechercher'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDropdown({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    final cities = LocationData.getCountries().expand((country) {
      return LocationData.getCitiesForCountry(country);
    }).toList();

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: cities.map((city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text('Choose $label'),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value != null
                    ? '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                    : 'Choose Date and Time',
                style: TextStyle(
                  color: value != null ? Colors.black : Colors.grey,
                ),
              ),
              const Icon(Icons.calendar_today, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}