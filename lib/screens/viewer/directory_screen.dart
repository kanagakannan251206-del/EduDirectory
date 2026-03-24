import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// FIXED: Essential import for navigation
import 'staff_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final staff = provider.filteredStaff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Directory'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          if (provider.searchQuery.isNotEmpty || 
              provider.selectedDepartment != 'All' || 
              provider.selectedRole != null || 
              provider.selectedAvailability != null ||
              provider.showEmergencyOnly)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: provider.clearFilters,
              tooltip: 'Clear Filters',
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          AppSearchBar(
            hint: 'Search by name, subject, ID...',
            onChanged: provider.setSearchQuery,
            initialValue: provider.searchQuery,
          ),
          
          // --- Collapsible Filter Panel ---
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _FilterPanel(provider: provider),
          ),
          
          // --- Results Count and Active Filter Chips ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${staff.length} result${staff.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDeep,
                  ),
                ),
                const Spacer(),
                if (provider.selectedDepartment != 'All')
                  _FilterChip(
                    label: provider.selectedDepartment,
                    onRemove: () => provider.setSelectedDepartment('All'),
                  ),
                if (provider.selectedRole != null)
                  _FilterChip(
                    label: provider.selectedRole!.label,
                    onRemove: () => provider.setSelectedRole(null),
                  ),
              ],
            ),
          ),
          
          // --- Staff List Results ---
          Expanded(
            child: staff.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No faculty matches found',
                    subtitle: 'Try adjusting your search terms or filters.',
                    actionLabel: 'Clear All Filters',
                    onAction: provider.clearFilters,
                  )
                : ListView.builder(
                    itemCount: staff.length,
                    padding: const EdgeInsets.only(bottom: 100), // Padding for FAB or BottomNav
                    itemBuilder: (ctx, i) {
                      final s = staff[i];
                      return StaffCard(
                        staff: s,
                        isFavorite: provider.isFavorite(s.id),
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => StaffDetailScreen(staffId: s.id),
                          ),
                        ),
                        onFavoriteToggle: () => provider.toggleFavorite(s.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final AppProvider provider;
  const _FilterPanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Refine Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy)),
              TextButton(onPressed: provider.clearFilters, child: const Text('Reset', style: TextStyle(fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          
          // Department Scroll
          _FilterSectionHeader(title: 'Department'),
          _ScrollFilterRow(
            items: ['All', ...provider.departments.map((d) => d.name)],
            selectedItem: provider.selectedDepartment,
            onSelect: (val) => provider.setSelectedDepartment(val),
          ),
          
          const SizedBox(height: 16),
          
          // Role Scroll
          _FilterSectionHeader(title: 'Academic Role'),
          _ScrollFilterRow(
            items: [null, ...StaffRole.values],
            selectedItem: provider.selectedRole,
            itemLabel: (role) => role == null ? 'All Roles' : (role as StaffRole).label,
            onSelect: (val) => provider.setSelectedRole(val as StaffRole?),
          ),
          
          const SizedBox(height: 16),
          
          // Availability Scroll
          _FilterSectionHeader(title: 'Status'),
          _ScrollFilterRow(
            items: [null, ...AvailabilityStatus.values],
            selectedItem: provider.selectedAvailability,
            itemLabel: (status) => status == null ? 'Any Status' : (status as AvailabilityStatus).label,
            onSelect: (val) => provider.setSelectedAvailability(val as AvailabilityStatus?),
          ),
          
          const SizedBox(height: 12),
          
          // Emergency Switch
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Emergency Contacts Only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            value: provider.showEmergencyOnly,
            onChanged: provider.setShowEmergencyOnly,
            activeColor: AppTheme.accentCoral,
          ),
        ],
      ),
    );
  }
}

// --- Internal UI Components ---

class _FilterSectionHeader extends StatelessWidget {
  final String title;
  const _FilterSectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
    );
  }
}

class _ScrollFilterRow extends StatelessWidget {
  final List<dynamic> items;
  final dynamic selectedItem;
  final String Function(dynamic)? itemLabel;
  final Function(dynamic) onSelect;

  const _ScrollFilterRow({required this.items, required this.selectedItem, this.itemLabel, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isSelected = selectedItem == item;
          final label = itemLabel != null ? itemLabel!(item) : item.toString();
          return GestureDetector(
            onTap: () => onSelect(item),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppTheme.primaryNavy : AppTheme.divider),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.primaryNavy, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.cancel, size: 14, color: AppTheme.primaryNavy),
          ),
        ],
      ),
    );
  }
}
