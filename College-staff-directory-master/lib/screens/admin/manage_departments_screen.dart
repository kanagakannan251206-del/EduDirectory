import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class ManageDepartmentsScreen extends StatelessWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Departments')),
      body: ListView.builder(
        itemCount: provider.departments.length,
        itemBuilder: (ctx, i) {
          final dept = provider.departments[i];
          final count = provider.departmentStaffCount[dept.name] ?? 0;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: dept.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.school, color: dept.color),
              ),
              title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${dept.code} • $count members • ${dept.building}', style: const TextStyle(fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: dept.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$count', style: TextStyle(color: dept.color, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showEditDialog(context, dept.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, String deptId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Department edit coming soon!')),
    );
  }
}
