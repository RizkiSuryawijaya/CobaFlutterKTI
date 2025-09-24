// File: lib/widgets/dummy_approved_section.dart
import 'package:flutter/material.dart';

class DummyApprovedSection extends StatelessWidget {
  const DummyApprovedSection({super.key});

  final List<Map<String, String>> _approvers = const [
    {"nik": "10000191", "name": "ISA RIFAI"},
    {"nik": "10000192", "name": "AGUNG HITA NUGRAHA"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Approver',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: List.generate(_approvers.length, (index) {
                final approver = _approvers[index];
                return _buildApproverRow(context, index + 1, approver);
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApproverRow(
    BuildContext context,
    int index,
    Map<String, String> approver,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index.',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE0E7FF),
            child: Icon(Icons.person, color: Color(0xFF0D47A1), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  approver['nik'] ?? '-',
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  approver['name'] ?? '-',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}