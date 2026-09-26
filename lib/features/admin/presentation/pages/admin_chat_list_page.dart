import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_and_found/features/admin/presentation/providers/admin_provider.dart';
import 'package:go_router/go_router.dart';

class AdminChatListPage extends ConsumerWidget {
  const AdminChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chats'),
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
    if (reports.isEmpty) return const Center(child: Text('No active discussions'));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return ListTile(
          onTap: () => context.push('/admin/chats/${report.id}'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline_rounded)),
          title: Text(report.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Ref: ${report.trackId}', style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded),
        );
      },
    );
  }
}
