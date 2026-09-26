import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_and_found/features/admin/presentation/providers/admin_provider.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/presentation/widgets/status_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_and_found/features/auth/presentation/providers/auth_provider.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'System Overview',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(allReportsProvider),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportsOverview(context, ref, reportsAsync),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildQuickAction(
              context,
              Icons.people_alt_rounded,
              'Manage Users',
              'View list of users and send notifications',
              () => context.go('/admin/users'),
            ),
            _buildQuickAction(
              context,
              Icons.assessment_rounded,
              'View Reports',
              'Check all submitted reports',
              () => context.go('/admin/reports'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/admin/reports'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecentReportsList(context, reportsAsync),
            const SizedBox(height: 32),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            context,
            Icons.notifications_active_rounded,
            'Broadcast Announcement',
            'Send to all active users',
          ),
          _buildQuickAction(
            context,
            Icons.security_rounded,
            'System Security Audit',
            'Review recent authentication logs',
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsOverview(BuildContext context, WidgetRef ref, AsyncValue<List<Report>> reportsAsync) {
    if (reportsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (reportsAsync.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error loading reports: ${reportsAsync.error}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.invalidate(allReportsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final reports = reportsAsync.value ?? [];
    return _buildStats(context, reports);
  }

  Widget _buildRecentReportsList(BuildContext context, AsyncValue<List<Report>> reportsAsync) {
    if (reportsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (reportsAsync.hasError) {
      return const SizedBox.shrink(); // Error already shown in overview
    }
    
    final reports = reportsAsync.value ?? [];
    if (reports.isEmpty) {
      return const Center(child: Text('No reports found in system'));
    }

    final recentReports = reports.take(5).toList();

    return Column(
      children: recentReports.map((report) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            onTap: () => context.push('/admin/reports/${report.id}'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.report_gmailerrorred_rounded),
            ),
            title: Text(report.trackId, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(report.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: StatusBadge(status: report.status),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStats(BuildContext context, List<Report> reports) {
    final total = reports.length;
    final pending = reports.where((r) => r.status == ReportStatus.pending).length;
    final inReview = reports.where((r) => r.status == ReportStatus.underReview).length;
    // Count both returned and closed/located as resolved for the dashboard overview
    final resolved = reports.where((r) => 
      r.status == ReportStatus.returned || 
      r.status == ReportStatus.closed || 
      r.status == ReportStatus.located
    ).length;

    return Column(
      children: [
        Row(
          children: [
            _StatItem(label: 'Total', value: total.toString(), color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            _StatItem(label: 'Pending', value: pending.toString(), color: Colors.orange),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatItem(label: 'Reviewing', value: inReview.toString(), color: Colors.blue),
            const SizedBox(width: 12),
            _StatItem(label: 'Resolved', value: resolved.toString(), color: Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String title, String subtitle, [VoidCallback? onTap]) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap ?? () {},
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}
