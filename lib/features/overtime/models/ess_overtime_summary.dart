class OvertimeSummary {
  final int pending;
  final int approved;
  final int rejected;
  final int cancel;
  final int withdraw;

  OvertimeSummary({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.cancel,
    required this.withdraw,
  });

  factory OvertimeSummary.fromJson(Map<String, dynamic> json) {
    return OvertimeSummary(
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      cancel: json['cancel'] ?? 0,
      withdraw: json['withdraw'] ?? 0,
    );
  }
}
