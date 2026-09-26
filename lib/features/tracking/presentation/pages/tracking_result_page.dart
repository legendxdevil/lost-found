import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_and_found/features/tracking/presentation/providers/tracking_provider.dart';
import 'package:lost_and_found/features/report/presentation/widgets/status_badge.dart';
import 'package:lost_and_found/shared/widgets/tracking_progress_bar.dart';
import 'package:lost_and_found/shared/widgets/track_id_badge.dart';
import 'package:go_router/go_router.dart';

class TrackingResultPage extends ConsumerStatefulWidget {
  final String trackId;

  const TrackingResultPage({super.key, required this.trackId});

  @override
  ConsumerState<TrackingResultPage> createState() => _TrackingResultPageState();
}

class _TrackingResultPageState extends ConsumerState<TrackingResultPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(trackingNotifierProvider.notifier).trackItem(widget.trackId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Item'),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, AsyncValue<dynamic> state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.hasError) {
      return _buildError(context, state.error.toString());
    }
    
    final report = state.value;
    if (report == null) {
      return const Center(child: Text('Unexpected error. Report is null.'));
    }
    
    return _buildContent(context, report);
  }

  Widget _buildContent(BuildContext context, dynamic report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: TrackIdBadge(trackId: report.trackId)),
          const SizedBox(height: 32),
          Text(
            'Current Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StatusBadge(status: report.status),
          const SizedBox(height: 32),
          TrackingProgressBar(status: report.status),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 24),
          _buildInfoTile(context, 'Category', report.category.toString().split('.').last.toUpperCase()),
          _buildInfoTile(context, 'Description', report.description),
          _buildInfoTile(context, 'Lost Location', report.lostLocation),
          _buildInfoTile(context, 'Date Reported', report.lostDate.toLocal().toString().split(' ')[0]),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/report-detail/${report.id}'),
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('View Full Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 64),
            const SizedBox(height: 24),
            Text(
              'No Report Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any report with Tracking ID: ${widget.trackId}. Please check the ID and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
