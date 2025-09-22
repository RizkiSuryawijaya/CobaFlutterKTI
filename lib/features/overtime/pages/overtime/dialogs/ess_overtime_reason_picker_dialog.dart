import 'package:flutter/material.dart';
import '../../../../reason/models/ess-overtime-reason.dart';

class ReasonPickerDialog extends StatefulWidget {
  final List<EssReasonOT> reasons;
  final EssReasonOT? initialSelected;

  const ReasonPickerDialog({
    super.key,
    required this.reasons,
    this.initialSelected,
  });

  @override
  State<ReasonPickerDialog> createState() => _ReasonPickerDialogState();
}

class _ReasonPickerDialogState extends State<ReasonPickerDialog> {
  final _searchController = TextEditingController();
  List<EssReasonOT> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.reasons;
    _searchController.addListener(_filter);
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() => _filtered = widget.reasons.where((r) => r.name.toLowerCase().contains(q)).toList());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Alasan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari alasan...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text("Tidak ada alasan yang ditemukan."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final reason = _filtered[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          color: reason.reasonId == widget.initialSelected?.reasonId ? Colors.blue[100] : Colors.white,
                          child: ListTile(
                            title: Text(reason.name),
                            onTap: () => Navigator.pop(context, reason),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Tutup", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
