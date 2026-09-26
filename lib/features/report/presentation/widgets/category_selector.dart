import 'package:flutter/material.dart';
import 'package:lost_and_found/features/report/domain/entities/report.dart';

class CategorySelector extends StatelessWidget {
  final ReportCategory selectedCategory;
  final Function(ReportCategory) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: ReportCategory.values.length,
          itemBuilder: (context, index) {
            final category = ReportCategory.values[index];
            final isSelected = selectedCategory == category;
            
            return InkWell(
              onTap: () => onCategorySelected(category),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForCategory(category),
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name[0].toUpperCase() + category.name.substring(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconForCategory(ReportCategory category) {
    switch (category) {
      case ReportCategory.electronics:
        return Icons.devices_rounded;
      case ReportCategory.documents:
        return Icons.description_rounded;
      case ReportCategory.keys:
        return Icons.vpn_key_rounded;
      case ReportCategory.bag:
        return Icons.shopping_bag_rounded;
      case ReportCategory.wallet:
        return Icons.account_balance_wallet_rounded;
      case ReportCategory.other:
        return Icons.category_rounded;
    }
  }
}
