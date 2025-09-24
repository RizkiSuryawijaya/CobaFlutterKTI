// File: lib/pages/dummy_shift_page.dart
import 'package:flutter/material.dart';

// Ubah DummyShiftPage jadi DummyShiftCard
class DummyShiftCard extends StatelessWidget {
  const DummyShiftCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, 
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Shift: NON-SHIFT 1 SENIN - KAMIS (08:00 - 16:30)",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 6),
              Text(
                "(Work)",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
