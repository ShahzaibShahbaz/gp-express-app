// lib/features/customer/screens/gp_information_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import '../../../core/constants/color_constants.dart';
import '../../auth/models/user_model.dart';
import '../../gp/models/mission_model.dart';

class GPInfoScreen extends StatefulWidget {
  final MissionModel mission;
  final UserModel gpData;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final int totalVols;

  const GPInfoScreen({
    Key? key,
    required this.mission,
    required this.gpData,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.totalVols = 0,
  }) : super(key: key);

  @override
  State<GPInfoScreen> createState() => _GPInfoScreenState();
}

class _GPInfoScreenState extends State<GPInfoScreen> {
  late final MapController _mapController;
  LatLng? _currentLocation;
  late Stream<Position> _positionStream;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _setupLocationTracking();
  }

  Future<void> _setupLocationTracking() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .asBroadcastStream();

    _positionStream.listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);
      if (_currentLocation == null) {
        // Initial position, center map
        _mapController.move(newLocation, _mapController.camera.zoom);
      }
      setState(() => _currentLocation = newLocation);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Infos GP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: widget.onFavoriteToggle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.gpData.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nom: ${widget.gpData.fullName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vol actuel: ${widget.mission.departureCity} → ${widget.mission.arrivalCity}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nombre total de vols: ${widget.totalVols}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Flight Path Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAirportInfo(
                    widget.mission.departureAirport,
                    widget.mission.departureTime,
                    true,
                  ),
                  const Icon(Icons.flight, color: AppColors.primaryBlue),
                  _buildAirportInfo(
                    widget.mission.arrivalAirport,
                    widget.mission.arrivalTime,
                    false,
                  ),
                ],
              ),
            ),

            // Map Section
            _buildMap(
              LatLng(widget.mission.departureLatitude, widget.mission.departureLongitude),
              LatLng(widget.mission.arrivalLatitude, widget.mission.arrivalLongitude),
            ),

            // Additional Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Départ actuel:', widget.mission.departureCity),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Capacité de transport:',
                      '${widget.mission.capacity} Kilogrammes'
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Discussion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                      label: const Text('Demande'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LatLng departureLatLng, LatLng arrivalLatLng) {
    final locationMarkerStream = _positionStream.map((position) =>
        LocationMarkerPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        ),
    );

    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation ?? _calculateCenter(departureLatLng, arrivalLatLng),
            initialZoom: _calculateZoom(departureLatLng, arrivalLatLng),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
            backgroundColor: const Color(0xFFE6E6E6), // Moved to MapOptions
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.gpexpress.app',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [departureLatLng, arrivalLatLng],
                  strokeWidth: 2,
                  color: Colors.red,

                  borderStrokeWidth: 1,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: departureLatLng,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Marker(
                  point: arrivalLatLng,
                  width: 30,
                  height: 30,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 5,
                        right: 5,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        size: 30,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            CurrentLocationLayer(
              positionStream: locationMarkerStream,
              style: LocationMarkerStyle(
                marker: DefaultLocationMarker(
                  color: AppColors.primaryBlue,

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAirportInfo(String code, DateTime time, bool isDeparture) {
    return Column(
      children: [
        Text(
          code,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} GMT',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  LatLng _calculateCenter(LatLng departure, LatLng arrival) {
    return LatLng(
      (departure.latitude + arrival.latitude) / 2,
      (departure.longitude + arrival.longitude) / 2,
    );
  }

  double _calculateZoom(LatLng departure, LatLng arrival) {
    final distance = const Distance().distance(departure, arrival);
    if (distance > 5000000) return 2;
    if (distance > 2000000) return 3;
    if (distance > 1000000) return 4;
    if (distance > 500000) return 5;
    if (distance > 100000) return 6;
    return 7;
  }
}