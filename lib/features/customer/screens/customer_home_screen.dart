// lib/features/customer/screens/customer_home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/color_constants.dart';
import '../widgets/mission_list_item.dart';
import '../widgets/map_placeholder.dart';
import '../widgets/search_bar.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'gpEx',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MissionSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement messaging
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Colis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const MapPlaceholder(),
            _buildSection(
              title: 'En arrivant près de chez vous',
              query: FirebaseFirestore.instance
                  .collection('missions')
                  .where('status', isEqualTo: 'arriving')
                  .limit(3),
            ),
            _buildSection(
              title: 'Demandes en attente',
              query: FirebaseFirestore.instance
                  .collection('missions')
                  .where('status', isEqualTo: 'pending')
                  .limit(3),
            ),
            _buildSection(
              title: 'En Route',
              query: FirebaseFirestore.instance
                  .collection('missions')
                  .where('status', isEqualTo: 'inProgress')
                  .limit(3),
            ),
            _buildSection(
              title: 'Demandes approuvées',
              query: FirebaseFirestore.instance
                  .collection('missions')
                  .where('status', isEqualTo: 'approved')
                  .limit(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Query<Map<String, dynamic>> query,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final missions = snapshot.data?.docs ?? [];

              if (missions.isEmpty) {
                return const Center(
                  child: Text('No missions available'),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: missions.length,
                itemBuilder: (context, index) {
                  final mission = missions[index].data() as Map<String, dynamic>;
                  return MissionListItem(
                    mission: mission,
                    onTap: () {
                      // TODO: Navigate to mission details
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}