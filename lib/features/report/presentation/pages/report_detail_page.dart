import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/presentation/providers/report_provider.dart';
import 'package:lost_and_found/features/report/presentation/widgets/status_badge.dart';
import 'package:lost_and_found/shared/widgets/track_id_badge.dart';

class ReportDetailPage extends ConsumerWidget {
  final String reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(watchReportProvider(reportId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              // Share logic
            },
          ),
        ],
      ),
      body: _buildBody(context, reportAsync),
      bottomNavigationBar: _buildBottomNav(context, reportAsync),
    );
  }

  Widget _buildBody(BuildContext context, AsyncValue<Report> reportAsync) {
    if (reportAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (reportAsync.hasError) {
      return Center(child: Text('Error: ${reportAsync.error}'));
    }
    final report = reportAsync.value;
    if (report == null) return const Center(child: Text('Report not found'));
    
    return _buildContent(context, report);
  }

  Widget _buildBottomNav(BuildContext context, AsyncValue<Report> reportAsync) {
    final report = reportAsync.value;
    if (report == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => context.push('/chat/${report.id}'),
        icon: const Icon(Icons.chat_bubble_rounded),
        label: const Text('Open Support Chat'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Report report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: report.status),
              Text(
                'Updated: ${report.lastUpdatedAt.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            report.category.name.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report.description,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          TrackIdBadge(trackId: report.trackId),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          _buildInfoRow(context, Icons.location_on_rounded, 'Location', report.lostLocation),
          const SizedBox(height: 20),
          _buildInfoRow(
            context, 
            Icons.calendar_today_rounded, 
            'Date Reported Lost', 
            report.lostDate.toLocal().toString().split(' ')[0],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            context, 
            Icons.person_rounded, 
            'Reporter', 
            report.userName,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Our team is reviewing your report. You will be notified of any updates.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
