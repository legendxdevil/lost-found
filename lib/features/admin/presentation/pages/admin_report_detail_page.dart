import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_and_found/features/report/presentation/providers/report_provider.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/presentation/widgets/status_badge.dart';
import 'package:lost_and_found/shared/widgets/track_id_badge.dart';
import 'package:lost_and_found/features/admin/presentation/providers/admin_provider.dart';
import 'package:go_router/go_router.dart';

class AdminReportDetailPage extends ConsumerWidget {
  final String reportId;

  const AdminReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(watchReportProvider(reportId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_rounded),
            onPressed: () => context.push('/admin/chats/$reportId'),
          ),
        ],
      ),
      body: _buildBody(context, ref, reportAsync),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AsyncValue<Report> reportAsync) {
    if (reportAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (reportAsync.hasError) {
      return Center(child: Text('Error: ${reportAsync.error}'));
    }
    
    final report = reportAsync.value;
    if (report == null) {
      return const Center(child: Text('Report not found'));
    }
    
    return _buildContent(context, ref, report);
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Report report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: TrackIdBadge(trackId: report.trackId)),
          const SizedBox(height: 32),
          _buildStatusManager(context, ref, report),
          const SizedBox(height: 40),
          const Text('Report Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('Reporter', report.userName),
          _buildInfoRow('Category', report.category.name.toUpperCase()),
          _buildInfoRow('Date Lost', report.lostDate.toLocal().toString().split(' ')[0]),
          _buildInfoRow('Location', report.lostLocation),
          _buildInfoRow('Description', report.description),
          const SizedBox(height: 40),
          _buildActionButtons(context, report),
        ],
      ),
    );
  }

  Widget _buildStatusManager(BuildContext context, WidgetRef ref, Report report) {
    final adminState = ref.watch(adminReportNotifierProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReportStatus>(
            value: report.status,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: ReportStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.name.toUpperCase()),
              );
            }).toList(),
            onChanged: adminState is AsyncLoading 
              ? null 
              : (newStatus) {
                  if (newStatus != null && newStatus != report.status) {
                    ref.read(adminReportNotifierProvider.notifier)
                       .updateReportStatus(report.id, newStatus);
                  }
                },
          ),
          if (adminState is AsyncError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                adminState.error.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Report report) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/admin/notify/${report.userId}'),
            icon: const Icon(Icons.send_rounded),
            label: const Text('Notify User'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/admin/chats/${report.id}'),
            icon: const Icon(Icons.chat_bubble_rounded),
            label: const Text('Open Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
