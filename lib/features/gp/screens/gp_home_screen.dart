// lib/features/gp/screens/home/gp_home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/gp_bottom_navbar.dart';
import '../../../../core/widgets/add_mission_fab.dart';

import 'package:provider/provider.dart';

import '../../../core/constants/color_constants.dart';
import '../../auth/providers/auth_provider.dart';
import 'add_mission_screen.dart';
import 'my_missions_screen.dart';

class GPHomeScreen extends StatefulWidget {
  const GPHomeScreen({super.key});

  @override
  State<GPHomeScreen> createState() => _GPHomeScreenState();
}

class _GPHomeScreenState extends State<GPHomeScreen> {
  int _selectedIndex = 1;

  void _onIndexChanged(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyMissionsScreen()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddMissionPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMissionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const GPHomeContent(),
      bottomNavigationBar: GPBottomNavBar(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onIndexChanged,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0, right: 25),
        child: AddMissionFAB(
          onPressed: _onAddMissionPressed,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class GPHomeContent extends StatelessWidget {
  const GPHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('gpEx', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.messenger_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('missions')
            .where('gpId', isEqualTo: context.read<AuthProvider>().user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final missions = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Objectif en Cours',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...missions
                  .where((m) => m['status'] != 'pending')
                  .map((mission) => _MissionCard(mission: mission)),
              const SizedBox(height: 24),
              const Text(
                'Mission En attente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...missions
                  .where((m) => m['status'] == 'pending')
                  .map((mission) => _MissionCard(mission: mission)),
            ],
          );
        },
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final QueryDocumentSnapshot mission;

  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final data = mission.data() as Map<String, dynamic>;
    final departureTime = DateTime.parse(data['departureTime']);
    final arrivalTime = DateTime.parse(data['arrivalTime']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.flight, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['departureCity']} → ${data['arrivalCity']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Dep: ${_formatDateTime(departureTime)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Arr: ${_formatDateTime(arrivalTime)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Capacity: ${data['capacity']} KG',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  '0%',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Status: ${data['status']}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Chat'),
                ),
                const SizedBox(width: 8),
                if (data['status'] == 'pending')
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Colis collecté'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}