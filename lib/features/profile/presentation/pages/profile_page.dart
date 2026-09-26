import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_and_found/features/auth/presentation/providers/auth_provider.dart';
import 'package:lost_and_found/features/report/presentation/providers/report_provider.dart';
import 'package:lost_and_found/features/report/presentation/widgets/status_badge.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final reportsAsync = ref.watch(myReportsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileHeader(context, user),
            const SizedBox(height: 32),
            _buildStatCards(context, reportsAsync),
            const SizedBox(height: 32),
            _buildReportsSection(context, reportsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            user?.name.substring(0, 1).toUpperCase() ?? '?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'User Name',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          user?.email ?? 'email@example.com',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatCards(BuildContext context, AsyncValue<List<Report>> reportsAsync) {
    if (reportsAsync.isLoading) return const SizedBox.shrink();
    if (reportsAsync.hasError) return const SizedBox.shrink();
    
    final reports = reportsAsync.value ?? [];
    final total = reports.length;
    final resolved = reports.where((r) => r.status == ReportStatus.returned).length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _StatCard(label: 'Reports', value: total.toString(), icon: Icons.assignment_outlined),
          const SizedBox(width: 16),
          _StatCard(label: 'Resolved', value: resolved.toString(), icon: Icons.check_circle_outline, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildReportsSection(BuildContext context, AsyncValue<List<Report>> reportsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'My Active Reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        _buildReportsList(context, reportsAsync),
      ],
    );
  }

  Widget _buildReportsList(BuildContext context, AsyncValue<List<Report>> reportsAsync) {
    if (reportsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (reportsAsync.hasError) {
      return Center(child: Text('Error: ${reportsAsync.error}'));
    }
    
    final reportsList = reportsAsync.value ?? [];
    if (reportsList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('No reports found', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: reportsList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reportsList[index];
        return ListTile(
          onTap: () => context.push('/report-detail/${report.id}'),
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
            child: const Icon(Icons.description_outlined, size: 20),
          ),
          title: Text(report.description, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(report.trackId, style: const TextStyle(fontSize: 12)),
          trailing: StatusBadge(status: report.status),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
