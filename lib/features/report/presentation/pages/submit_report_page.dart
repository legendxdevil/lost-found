import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';
import 'package:lost_and_found/features/report/presentation/providers/report_provider.dart';
import 'package:lost_and_found/features/report/presentation/widgets/category_selector.dart';
import 'package:lost_and_found/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:lost_and_found/shared/widgets/track_id_badge.dart';

class SubmitReportPage extends ConsumerStatefulWidget {
  const SubmitReportPage({super.key});

  @override
  ConsumerState<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends ConsumerState<SubmitReportPage> {
  int _currentStep = 0;
  ReportCategory _selectedCategory = ReportCategory.other;
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Report? _submittedReport;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() async {
    final report = await ref.read(reportNotifierProvider.notifier).submitReport(
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          lostLocation: _locationController.text.trim(),
          lostDate: _selectedDate,
        );
    
    if (report != null && mounted) {
      setState(() {
        _submittedReport = report;
        _currentStep = 3; // Success step
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Report'),
        leading: _currentStep > 0 && _currentStep < 3
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        elevation: 0,
        controlsBuilder: (context, details) {
          if (_currentStep == 3) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: state is AsyncLoading ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: state is AsyncLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_currentStep == 2 ? 'Submit Report' : 'Continue'),
                  ),
                ),
              ],
            ),
          );
        },
        onStepContinue: () {
          if (_currentStep == 0) {
            setState(() => _currentStep++);
          } else if (_currentStep == 1) {
            if (_descriptionController.text.isNotEmpty && _locationController.text.isNotEmpty) {
              setState(() => _currentStep++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
            }
          } else if (_currentStep == 2) {
            _submit();
          }
        },
        steps: [
          Step(
            title: const Text('Category'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),
          Step(
            title: const Text('Details'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                AuthTextField(
                  controller: _descriptionController,
                  label: 'Item Description',
                  hintText: 'Color, brand, unique marks...',
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _locationController,
                  label: 'Lost Location',
                  hintText: 'Where did you lose it?',
                ),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date Lost', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () => _selectDate(context),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Confirm'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem('Category', _selectedCategory.name.toUpperCase()),
                _buildSummaryItem('Description', _descriptionController.text),
                _buildSummaryItem('Location', _locationController.text),
                _buildSummaryItem('Date', "${_selectedDate.toLocal()}".split(' ')[0]),
              ],
            ),
          ),
          Step(
            title: const Text('Success'),
            isActive: _currentStep >= 3,
            state: StepState.complete,
            content: Column(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Report Submitted!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep this tracking ID to follow progress',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                if (_submittedReport != null)
                  TrackIdBadge(trackId: _submittedReport!.trackId),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Go to Home'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
