import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_and_found/features/admin/presentation/providers/admin_provider.dart';
import 'package:lost_and_found/features/report/presentation/widgets/status_badge.dart';
import 'package:go_router/go_router.dart';

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All System Reports'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Filter by Tracking ID...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (val) {
                // Filter logic
              },
            ),
          ),
        ),
      ),
      body: _buildBody(context, reportsAsync),
    );
  }

  Widget _buildBody(BuildContext context, AsyncValue<List<dynamic>> reportsAsync) {
    if (reportsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (reportsAsync.hasError) {
      return Center(child: Text('Error: ${reportsAsync.error}'));
    }
    
    final reports = reportsAsync.value ?? [];
    if (reports.isEmpty) {
      return const Center(child: Text('No reports found in system'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return ListTile(
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
        );
      },
    );
  }
}
