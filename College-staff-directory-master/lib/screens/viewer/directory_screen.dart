import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
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
          if (provider.searchQuery.isNotEmpty || provider.selectedDepartment != 'All' || provider.selectedRole != null)
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilters ? null : 0,
            child: _showFilters ? _FilterPanel(provider: provider) : const SizedBox(),
          ),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${staff.length} result${staff.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Department filter chips
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
          Expanded(
            child: staff.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: 'No Faculty Found',
                    subtitle: 'Try adjusting your search or filters',
                    actionLabel: 'Clear Filters',
                    onAction: provider.clearFilters,
                  )
                : ListView.builder(
                    itemCount: staff.length,
                    itemBuilder: (ctx, i) {
                      final s = staff[i];
                      return StaffCard(
                        staff: s,
                        isFavorite: provider.isFavorite(s.id),
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: s.id)),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter By', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          // Department
          Text('Department', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', ...provider.departments.map((d) => d.name)].map((dept) {
                final sel = provider.selectedDepartment == dept;
                return GestureDetector(
                  onTap: () => provider.setSelectedDepartment(dept),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primaryNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppTheme.primaryNavy : AppTheme.divider),
                    ),
                    child: Text(
                      dept,
                      style: TextStyle(
                        color: sel ? Colors.white : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Role
          Text('Role', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [null, ...StaffRole.values].map((role) {
                final sel = provider.selectedRole == role;
                return GestureDetector(
                  onTap: () => provider.setSelectedRole(role),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primaryNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppTheme.primaryNavy : AppTheme.divider),
                    ),
                    child: Text(
                      role?.label ?? 'All Roles',
                      style: TextStyle(
                        color: sel ? Colors.white : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Availability
          Text('Availability', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [null, ...AvailabilityStatus.values].map((status) {
              final sel = provider.selectedAvailability == status;
              final color = status?.color ?? AppTheme.primaryNavy;
              return GestureDetector(
                onTap: () => provider.setSelectedAvailability(status),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? color.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? color : AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      if (status != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        status?.label ?? 'All',
                        style: TextStyle(color: sel ? color : AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          // Emergency
          Row(
            children: [
              Switch(
                value: provider.showEmergencyOnly,
                onChanged: provider.setShowEmergencyOnly,
                activeThumbColor: AppTheme.accentCoral,
              ),
              Text('Emergency contacts only', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.primaryNavy, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppTheme.primaryNavy),
          ),
        ],
      ),
    );
  }
}
