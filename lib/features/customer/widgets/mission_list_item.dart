// lib/features/customer/widgets/mission_list_item.dart

import 'package:flutter/material.dart';
import '../../../core/constants/color_constants.dart';

class MissionListItem extends StatelessWidget {
  final Map<String, dynamic> mission;
  final VoidCallback onTap;

  const MissionListItem({
    Key? key,
    required this.mission,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Add this
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      radius: 20,
                      child: Text(
                        mission['gpName']?.substring(0, 1).toUpperCase() ?? 'G',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${mission['departureCity']} → ${mission['arrivalCity']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            mission['gpName'] ?? 'GP Name',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Dep:',
                        mission['departureTime'] ?? 'N/A',
                      ),
                      const SizedBox(height: 2),
                      _buildInfoRow(
                        'Arr:',
                        mission['arrivalTime'] ?? 'N/A',
                      ),
                      const SizedBox(height: 2),
                      _buildInfoRow(
                        'Capacity:',
                        '${mission['capacity'] ?? 0} KG',
                      ),
                    ],
                  ),
                ),
                if (mission['status'] == 'inProgress') ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: mission['completionPercentage'] ?? 0.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${((mission['completionPercentage'] ?? 0.0) * 100).toStringAsFixed(0)}% COMPLETED',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}