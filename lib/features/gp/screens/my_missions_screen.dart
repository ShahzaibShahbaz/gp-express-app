import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/widgets/gp_bottom_navbar.dart';
import '../../../core/widgets/add_mission_fab.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/mission_model.dart';
import 'add_mission_screen.dart';
import 'gp_home_screen.dart';

class MyMissionsScreen extends StatefulWidget {
  const MyMissionsScreen({Key? key}) : super(key: key);

  @override
  State<MyMissionsScreen> createState() => _MyMissionsScreenState();
}

class _MyMissionsScreenState extends State<MyMissionsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user?.uid;

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
            .where('gpId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final missions = snapshot.data?.docs
              .map((doc) => MissionModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ))
              .toList() ?? [];

          final totalCapacity = missions.fold<int>(0,
                  (sum, mission) => sum + mission.capacity);
          final usedCapacity = missions
              .where((m) => m.status == MissionStatus.approved)
              .fold<int>(0, (sum, mission) => sum + mission.capacity);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CapacityIndicator(used: usedCapacity, total: 10),
              const SizedBox(height: 24),
              const Text(
                'Mission approuvées',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...missions
                  .where((m) => m.status == MissionStatus.approved)
                  .map((m) => _MissionCard(
                mission: m,
                isApproved: true,
              )),
              const SizedBox(height: 24),
              const Text(
                'Mission En attente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...missions
                  .where((m) => m.status == MissionStatus.pending)
                  .map((m) => _MissionCard(
                mission: m,
                isApproved: false,
              )),
            ],
          );
        },
      ),
      bottomNavigationBar: GPBottomNavBar(
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GPHomeScreen()),
            );
          }
          setState(() => _selectedIndex = index);
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0, right: 25),
        child: AddMissionFAB(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddMissionScreen()),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _CapacityIndicator extends StatelessWidget {
  final int used;
  final int total;

  const _CapacityIndicator({required this.used, required this.total});

  @override
  Widget build(BuildContext context) {
    final percentage = (used / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Capacité de poids',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('$used/$total Kg'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: used / total,
          backgroundColor: Colors.grey[300],
          color: AppColors.primaryBlue,
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          'jusqu\'à le fin de poids',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  final MissionModel mission;
  final bool isApproved;

  const _MissionCard({required this.mission, required this.isApproved});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[200],
                  child: const Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.customerName ?? 'Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${mission.departureCity} → ${mission.arrivalCity}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dep: ${_formatDateTime(mission.departureTime)}'),
            Text('Arr: ${_formatDateTime(mission.arrivalTime)}'),
            Text('Capacity: ${mission.capacity} KG'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isApproved) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status: Encore à partir'),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: mission.completionPercentage ?? 0.2,
                          backgroundColor: Colors.grey[300],
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Text(
                        '${(mission.completionPercentage ?? 0.2) * 100}% COMPLETED',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Chat'),
                  ),
                ] else
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accepter (expire dans 2 jours)'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute} EST';
  }
}