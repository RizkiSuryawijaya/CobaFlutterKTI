import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          _buildStep("1", "Form", currentStep >= 1, currentStep == 1),
          _buildLine(currentStep >= 2),
          _buildStep("2", "Kirim", currentStep >= 2, currentStep == 2),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String label, bool isActive, bool isCurrent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[900] : Colors.grey[300],
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: Colors.blue[700]!, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? Colors.blue[900] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Colors.blue[900] : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
