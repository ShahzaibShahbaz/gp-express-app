// lib/features/customer/screens/matching_gp_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/color_constants.dart';
import '../models/request_model.dart';
import '../widgets/gp_card.dart';

class MatchingGPsScreen extends StatefulWidget {
  final RequestModel request;

  const MatchingGPsScreen({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  State<MatchingGPsScreen> createState() => _MatchingGPsScreenState();
}

class _MatchingGPsScreenState extends State<MatchingGPsScreen> {
  late Stream<QuerySnapshot> _missionsStream;

  @override
  void initState() {
    super.initState();
    _initMissionsStream();
  }

  void _initMissionsStream() {
    debugPrint('Request Data:');
    debugPrint('Departure City: ${widget.request.departureCity}');
    debugPrint('Arrival City: ${widget.request.arrivalCity}');
    debugPrint('Earliest Departure: ${widget.request.earliestDepartureTime}');
    debugPrint('Latest Arrival: ${widget.request.latestArrivalTime}');
    debugPrint('Weight: ${widget.request.weight}');

    // Query with basic filters
    Query query = FirebaseFirestore.instance.collection('missions')
        .where('status', whereIn: ['pending', 'approved'])
        .where('departureCity', isEqualTo: widget.request.departureCity)
        .where('arrivalCity', isEqualTo: widget.request.arrivalCity);

    _missionsStream = query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Résultats correspondants',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _missionsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Stream Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final missions = snapshot.data?.docs ?? [];
          debugPrint('Found ${missions.length} missions');

          // Filter missions based on time and capacity
          final matchingMissions = missions.where((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;

              // Safely parse departure and arrival times
              final departureTime = data['departureTime'] is Timestamp
                  ? (data['departureTime'] as Timestamp).toDate()
                  : DateTime.parse(data['departureTime'].toString());

              final arrivalTime = data['arrivalTime'] is Timestamp
                  ? (data['arrivalTime'] as Timestamp).toDate()
                  : DateTime.parse(data['arrivalTime'].toString());

              final capacity = (data['capacity'] ?? 0) as num;

              debugPrint('Checking mission:');
              debugPrint('Departure: $departureTime');
              debugPrint('Arrival: $arrivalTime');
              debugPrint('Capacity: $capacity');

              return departureTime.isAfter(widget.request.earliestDepartureTime.subtract(const Duration(hours: 1))) &&
                  arrivalTime.isBefore(widget.request.latestArrivalTime.add(const Duration(hours: 1))) &&
                  capacity >= widget.request.weight;
            } catch (e) {
              debugPrint('Error processing mission: $e');
              return false;
            }
          }).toList();

          if (matchingMissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No matching GPs found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matchingMissions.length,
            itemBuilder: (context, index) {
              final mission = matchingMissions[index].data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(mission['gpId'])
                    .get(),
                builder: (context, gpSnapshot) {
                  if (!gpSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final gpData = gpSnapshot.data!.data() as Map<String, dynamic>;

                  return GPCard(
                    gpData: {
                      ...mission,
                      'gpId': mission['gpId'],
                      'gpName': gpData['fullName'] ?? 'GP Name',
                      'departureTime': mission['departureTime'] is Timestamp
                          ? (mission['departureTime'] as Timestamp).toDate().toString()
                          : mission['departureTime'].toString(),
                      'arrivalTime': mission['arrivalTime'] is Timestamp
                          ? (mission['arrivalTime'] as Timestamp).toDate().toString()
                          : mission['arrivalTime'].toString(),
                    },
                    isFavorite: false,
                    onFavoriteToggle: () {},
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}