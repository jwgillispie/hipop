import 'package:flutter/material.dart';
import '../../models/unified_search_result.dart';

class UnifiedResultCard extends StatelessWidget {
  final SearchResultItem result;
  final VoidCallback? onTap;

  const UnifiedResultCard({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (result.distance != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${result.distance!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      result.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              if (result.type == SearchResultType.independentVendor && result.vendorPost != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getVendorEventInfo(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (result.type) {
      case SearchResultType.market:
        return Colors.green;
      case SearchResultType.independentVendor:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon() {
    switch (result.type) {
      case SearchResultType.market:
        return Icons.store_mall_directory;
      case SearchResultType.independentVendor:
        return Icons.location_on;
    }
  }

  String _getVendorEventInfo() {
    if (result.vendorPost == null) return '';
    
    final vendorPost = result.vendorPost!;
    final now = DateTime.now();
    final startTime = vendorPost.popUpStartDateTime;
    final endTime = vendorPost.popUpEndDateTime;
    
    // Check if event is today
    if (startTime.year == now.year && 
        startTime.month == now.month && 
        startTime.day == now.day) {
      return 'Today ${_formatTime(startTime)} - ${_formatTime(endTime)}';
    }
    
    // Check if event is tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    if (startTime.year == tomorrow.year && 
        startTime.month == tomorrow.month && 
        startTime.day == tomorrow.day) {
      return 'Tomorrow ${_formatTime(startTime)} - ${_formatTime(endTime)}';
    }
    
    // Show date
    return '${startTime.month}/${startTime.day} ${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}