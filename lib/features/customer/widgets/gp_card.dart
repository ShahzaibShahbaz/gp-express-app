// lib/features/customer/widgets/gp_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/feedback_utils.dart';
import '../../auth/models/user_model.dart';
import '../../gp/models/mission_model.dart';

import '../providers/gp_provider.dart';
import '../screens/gp_infomation_screen.dart';


class GPCard extends StatelessWidget {
  final Map<String, dynamic> gpData;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const GPCard({
    Key? key,
    required this.gpData,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime date = dateTime is Timestamp
          ? dateTime.toDate()
          : DateTime.parse(dateTime.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} GMT';
    } catch (e) {
      return 'N/A';
    }
  }

  void _navigateToGPInfo(BuildContext context) async {
    try {
      // Convert gpData to MissionModel
      final mission = MissionModel(
        id: gpData['id'] ?? '',
        gpId: gpData['gpId'] ?? '',
        departureCountry: gpData['departureCountry'] ?? '',
        departureCity: gpData['departureCity'] ?? '',
        departureAirport: gpData['departureAirport'] ?? '',
        departureLatitude: (gpData['departureLatitude'] ?? 0.0).toDouble(),
        departureLongitude: (gpData['departureLongitude'] ?? 0.0).toDouble(),
        arrivalCountry: gpData['arrivalCountry'] ?? '',
        arrivalCity: gpData['arrivalCity'] ?? '',
        arrivalAirport: gpData['arrivalAirport'] ?? '',
        arrivalLatitude: (gpData['arrivalLatitude'] ?? 0.0).toDouble(),
        arrivalLongitude: (gpData['arrivalLongitude'] ?? 0.0).toDouble(),
        departureTime: DateTime.parse(gpData['departureTime'].toString()),
        arrivalTime: DateTime.parse(gpData['arrivalTime'].toString()),
        capacity: gpData['capacity'] ?? 0,
        hasFlightTicket: gpData['hasFlightTicket'] ?? false,
        status: MissionStatus.values.firstWhere(
              (e) => e.name == (gpData['status'] ?? 'pending'),
          orElse: () => MissionStatus.pending,
        ),
        createdAt: (gpData['createdAt'] as Timestamp).toDate(),
      );
      // Create UserModel for GP
      final gpUser = UserModel(
        uid: gpData['gpId'] ?? '',
        email: gpData['gpEmail'] ?? '',
        fullName: gpData['gpName'] ?? '',
        userType: UserType.gp,
        phoneNumber: gpData['gpPhone'],
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GPInfoScreen(
            mission: mission,
            gpData: gpUser,
            isFavorite: isFavorite,
            onFavoriteToggle: () async {
              try {
                await context.read<GPProvider>().toggleFavorite(gpData['gpId']);
                if (context.mounted) {
                  FeedbackUtils.showSuccessSnackBar(
                    context,
                    isFavorite ? 'Removed from favorites' : 'Added to favorites',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  FeedbackUtils.showErrorSnackBar(
                    context,
                    'Failed to update favorites: $e',
                  );
                }
              }
            },
          ),
        ),
      );
    } catch (e) {
      FeedbackUtils.showErrorSnackBar(
        context,
        'Error opening GP details: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToGPInfo(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: Text(
                      gpData['gpName']?.toString().substring(0, 1).toUpperCase() ?? 'G',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // GP Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${gpData['departureCity']} → ${gpData['arrivalCity']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gpData['gpName']?.toString() ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Favorite Button
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFavorite),
                        color: isFavorite ? AppColors.primaryBlue : Colors.grey,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await context.read<GPProvider>().toggleFavorite(gpData['gpId']);
                        if (context.mounted) {
                          FeedbackUtils.showSuccessSnackBar(
                            context,
                            isFavorite ? 'Removed from favorites' : 'Added to favorites',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          FeedbackUtils.showErrorSnackBar(
                            context,
                            'Failed to update favorites: $e',
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            // Trip Details
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  _buildInfoRow('Dep:', _formatDateTime(gpData['departureTime'])),
                  const SizedBox(height: 4),
                  _buildInfoRow('Arr:', _formatDateTime(gpData['arrivalTime'])),
                  const SizedBox(height: 4),
                  _buildInfoRow('Capacity:', '${gpData['capacity']?.toString() ?? '0'} kg'),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}