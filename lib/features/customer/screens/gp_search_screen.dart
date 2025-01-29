// lib/features/customer/screens/gp_search_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../providers/gp_provider.dart';
import '../widgets/gp_card.dart';
import '../widgets/search_filter_sheet.dart';

class GPSearchScreen extends StatefulWidget {
  const GPSearchScreen({Key? key}) : super(key: key);

  @override
  State<GPSearchScreen> createState() => _GPSearchScreenState();
}

class _GPSearchScreenState extends State<GPSearchScreen> {
  bool _showFavorites = false;
  final TextEditingController _searchController = TextEditingController();

  String? _departureCity;
  String? _arrivalCity;
  DateTime? _departureTime;
  DateTime? _arrivalTime;
  int? _minCapacity;

  String _calculateDuration(dynamic departure, dynamic arrival) {
    try {
      final dep = departure is Timestamp ? departure.toDate() : DateTime.parse(departure.toString());
      final arr = arrival is Timestamp ? arrival.toDate() : DateTime.parse(arrival.toString());
      final difference = arr.difference(dep);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      return '${hours}h${minutes.toString().padLeft(2, '0')}m';
    } catch (e) {
      return 'N/A';
    }
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterSheet(
        initialFilters: {
          'departureCity': _departureCity,
          'arrivalCity': _arrivalCity,
          'departureTime': _departureTime,
          'arrivalTime': _arrivalTime,
          'minCapacity': _minCapacity,
        },
      ),
    );

    if (result != null) {
      setState(() {
        _departureCity = result['departureCity'];
        _arrivalCity = result['arrivalCity'];
        _departureTime = result['departureTime'];
        _arrivalTime = result['arrivalTime'];
        _minCapacity = result['minCapacity'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
            ),
            child: Column(
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search GP's to your match",
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _showFilterSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Custom Tab Bar
          Container(
            color: AppColors.primaryBlue,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showFavorites = false),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text(
                              'Autres',
                              style: TextStyle(
                                color: !_showFavorites ? AppColors.primaryBlue : Colors.grey,
                                fontWeight: !_showFavorites ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(
                            height: 2,
                            color: !_showFavorites ? AppColors.primaryBlue : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showFavorites = true),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text(
                              'Favoris',
                              style: TextStyle(
                                color: _showFavorites ? AppColors.primaryBlue : Colors.grey,
                                fontWeight: _showFavorites ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          Container(
                            height: 2,
                            color: _showFavorites ? AppColors.primaryBlue : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // GP List
          Expanded(
            child: _buildGPList(
              context.watch<GPProvider>(),
              _showFavorites,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPList(GPProvider provider, bool favoritesOnly) {
    debugPrint('Building GP List: favorites=$favoritesOnly');
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getGPMissions(
        departureCity: _departureCity,
        arrivalCity: _arrivalCity,
        departureTime: _departureTime,
        arrivalTime: _arrivalTime,
        minCapacity: _minCapacity,
        favoritesOnly: favoritesOnly,
      ),
      builder: (context, snapshot) {
        debugPrint('Stream Builder State: ${snapshot.connectionState}');
        debugPrint('Stream Builder Error: ${snapshot.error}');
        debugPrint('Stream Builder Has Data: ${snapshot.hasData}');

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final missions = snapshot.data?.docs ?? [];
        debugPrint('Found ${missions.length} missions');

        if (missions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  favoritesOnly
                      ? 'No favorite GPs found'
                      : 'No GPs found matching your criteria',
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
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index].data() as Map<String, dynamic>;
            debugPrint('Mission Data: $mission');
            final gpId = mission['gpId'] as String;

            return FutureBuilder<Map<String, dynamic>?>(
              future: provider.getGPDetails(gpId),
              builder: (context, gpSnapshot) {
                if (gpSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final gpData = gpSnapshot.data;
                debugPrint('GP Data for $gpId: $gpData');
                if (gpData == null) return const SizedBox.shrink();

                final fullMissionData = {
                  ...mission,
                  'gpName': gpData['fullName'],
                  'gpAvatar': gpData['avatarUrl'],
                  'departureCity': mission['departureCity'],
                  'arrivalCity': mission['arrivalCity'],
                  'departureTime': mission['departureTime'],
                  'arrivalTime': mission['arrivalTime'],
                  'capacity': mission['capacity'],
                  // Add these fields for the map
                  'departureLat': mission['departureLat'], // Make sure these exist in Firestore
                  'departureLon': mission['departureLon'],
                  'arrivalLat': mission['arrivalLat'],
                  'arrivalLon': mission['arrivalLon'],
                  // Add airport codes
                  'departureAirport': mission['departureAirport'] ?? 'DSS',
                  'arrivalAirport': mission['arrivalAirport'] ?? 'CDG',
                  'flightDuration': _calculateDuration(
                      mission['departureTime'],
                      mission['arrivalTime']
                  ),
                };

                return GPCard(
                  gpData: fullMissionData,
                  isFavorite: provider.favoriteGPs.contains(gpId),
                  onFavoriteToggle: () => provider.toggleFavorite(gpId),
                );
              },
            );
          },
        );
      },
    );
  }
}