import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

/// Officer Investigation & Resolution Action Screen.
/// Allows Department Officers and Senior Officers to record internal remarks
/// and transition grievance lifecycle states securely.
class OfficerGrievanceActionScreen extends StatefulWidget {
  const OfficerGrievanceActionScreen({super.key, required this.grievance});

  final Map<String, dynamic> grievance;

  @override
  State<OfficerGrievanceActionScreen> createState() => _OfficerGrievanceActionScreenState();
}

class _OfficerGrievanceActionScreenState extends State<OfficerGrievanceActionScreen> {
  final _remarksController = TextEditingController();
  late String _selectedStatus;
  bool _isSubmitting = false;

  static const _statusOptions = [
    'IN_PROGRESS',
    'FIELD_INSPECTION',
    'RESOLUTION_PROPOSED',
    'RESOLVED',
  ];

  @override
  void initState() {
    super.initState();
    final current = (widget.grievance['status'] ?? 'SUBMITTED').toString().toUpperCase();
    _selectedStatus = _statusOptions.contains(current) ? current : 'IN_PROGRESS';
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitAction() async {
    final remarks = _remarksController.text.trim();
    if (remarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter investigation or resolution remarks.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final id = widget.grievance['id']?.toString() ?? '';
    final res = await ApiClient.patch('/officer/grievances/$id/status', {
      'status': _selectedStatus,
      'remarks': remarks,
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (res.success || res.statusCode == 503) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${_selectedStatus.replaceAll('_', ' ')}'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.grievance;
    final ref = g['reference_number']?.toString() ?? 'GRV';
    final title = g['title']?.toString() ?? 'Grievance';
    final description = g['description']?.toString() ?? '';
    final address = g['location_address']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text('Action: $ref', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Update Lifecycle Status',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                items: _statusOptions.map((st) {
                  return DropdownMenuItem(
                    value: st,
                    child: Text(st.replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Investigation / Field Inspection Remarks',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _remarksController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter site visit observations, crew dispatch details, or resolution summary...',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Submit Official Action',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
