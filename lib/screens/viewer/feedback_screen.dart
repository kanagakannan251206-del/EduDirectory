import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  final StaffMember staff;
  const FeedbackScreen({super.key, required this.staff});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'feedback';
  String _category = 'General';
  final _msgCtrl = TextEditingController();
  double _rating = 0;

  final _categories = ['General', 'Office Hours', 'Contact Info', 'Profile Photo', 'Other'];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final feedback = FeedbackReport(
      id: const Uuid().v4(),
      staffId: widget.staff.id,
      reporterId: provider.currentUser?.id ?? 'anonymous',
      type: _type,
      category: _category,
      message: _msgCtrl.text.trim(),
      createdAt: DateTime.now(),
      rating: _rating > 0 ? _rating : null,
    );
    provider.submitFeedback(feedback);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you! Your feedback has been submitted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedback: ${widget.staff.name.split(' ').first}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _TypeBtn(label: 'Feedback', value: 'feedback', selected: _type, onTap: (v) => setState(() => _type = v), icon: Icons.star_outline, color: AppTheme.accentGold)),
                  const SizedBox(width: 8),
                  Expanded(child: _TypeBtn(label: 'Report', value: 'report', selected: _type, onTap: (v) => setState(() => _type = v), icon: Icons.flag_outlined, color: AppTheme.accentCoral)),
                  const SizedBox(width: 8),
                  Expanded(child: _TypeBtn(label: 'Update Request', value: 'update_request', selected: _type, onTap: (v) => setState(() => _type = v), icon: Icons.edit_outlined, color: AppTheme.accentTeal)),
                ],
              ),
              const SizedBox(height: 20),
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final sel = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primaryNavy : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? AppTheme.primaryNavy : AppTheme.divider),
                      ),
                      child: Text(cat, style: TextStyle(color: sel ? Colors.white : AppTheme.textSecondary, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              if (_type == 'feedback') ...[
                const SizedBox(height: 20),
                Text('Rating (Optional)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) => GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: AppTheme.accentGold,
                        size: 32,
                      ),
                    ),
                  )),
                ),
              ],
              const SizedBox(height: 20),
              Text('Message', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _msgCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: _type == 'feedback' ? 'Share your experience...' : _type == 'report' ? 'Describe the issue...' : 'What information needs updating?',
                ),
                validator: (v) => v!.isEmpty ? 'Please enter a message' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label, value, selected;
  final Function(String) onTap;
  final IconData icon;
  final Color color;
  const _TypeBtn({required this.label, required this.value, required this.selected, required this.onTap, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final sel = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? color : AppTheme.divider, width: sel ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: sel ? color : AppTheme.textMuted, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: sel ? color : AppTheme.textMuted, fontWeight: sel ? FontWeight.w600 : FontWeight.normal), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
