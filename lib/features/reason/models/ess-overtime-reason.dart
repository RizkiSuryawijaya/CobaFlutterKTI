class EssReasonOT {
  final String? reasonId;
  final String kodeReason;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  EssReasonOT({
    this.reasonId,
    required this.kodeReason,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory EssReasonOT.fromJson(Map<String, dynamic> json) {
    return EssReasonOT(
      reasonId: json['reason_id']?.toString(),
      kodeReason: (json['kodeReason'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason_id': reasonId,
      'kodeReason': kodeReason,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}