//lib/core/services/geocoding_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  Future<Map<String, double>> getCoordinates(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = 'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'GPExpress_App'},
      );

      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        if (results.isNotEmpty) {
          return {
            'latitude': double.parse(results[0]['lat']),
            'longitude': double.parse(results[0]['lon']),
          };
        }
      }

      // Return default coordinates if geocoding fails
      return {'latitude': 0.0, 'longitude': 0.0};
    } catch (e) {
      print('Geocoding error: $e');
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }
}