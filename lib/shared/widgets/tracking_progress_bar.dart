import 'package:flutter/material.dart';
import '../../features/report/domain/entities/report.dart';

class TrackingProgressBar extends StatelessWidget {
  final ReportStatus status;

  const TrackingProgressBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ReportStatus.pending,
      ReportStatus.underReview,
      ReportStatus.located,
      ReportStatus.returned,
    ];

    final currentIndex = steps.indexOf(status);
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isCompleted = index <= currentIndex;
            final isLast = index == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isCompleted && index < currentIndex
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isCompleted ? Colors.white : theme.colorScheme.outline,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted && (index < currentIndex)
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((s) {
            final isCurrent = s == status;
            return Text(
              _getStatusLabel(s),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Reviewing';
      case ReportStatus.located:
        return 'Located';
      case ReportStatus.returned:
        return 'Returned';
      case ReportStatus.closed:
        return 'Closed';
    }
  }
}
