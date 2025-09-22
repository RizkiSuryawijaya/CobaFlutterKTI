import 'dart:convert';

class EssConfigOvertime {
  final String id;
  final double monthlyTotalDurationHours;
  final int restTimeMinutes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EssConfigOvertime({
    required this.id,
    required this.monthlyTotalDurationHours,
    required this.restTimeMinutes,
    this.createdAt,
    this.updatedAt,
  });

  /// CopyWith agar bisa update sebagian field
  EssConfigOvertime copyWith({
    String? id,
    double? monthlyTotalDurationHours,
    int? restTimeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EssConfigOvertime(
      id: id ?? this.id,
      monthlyTotalDurationHours:
          monthlyTotalDurationHours ?? this.monthlyTotalDurationHours,
      restTimeMinutes: restTimeMinutes ?? this.restTimeMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Konversi dari Map (biasanya dari API/DB)
  factory EssConfigOvertime.fromMap(Map<String, dynamic> map) {
    return EssConfigOvertime(
      id: map['config_overtime_id']?.toString() ?? '',
      monthlyTotalDurationHours:
          (map['monthly_total_duration_hours'] as num?)?.toDouble() ?? 0.0,
      restTimeMinutes: map['rest_time_minutes'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  /// Konversi ke Map penuh (biasanya untuk debug saja)
  Map<String, dynamic> toMap() {
    return {
      'config_overtime_id': id,
      'monthly_total_duration_hours': monthlyTotalDurationHours,
      'rest_time_minutes': restTimeMinutes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Konversi ke Map khusus Create/Update (tanpa id, created_at, updated_at)
  Map<String, dynamic> toCreateMap() {
    return {
      'monthly_total_duration_hours': monthlyTotalDurationHours,
      'rest_time_minutes': restTimeMinutes,
    };
  }

  /// JSON Encode untuk create/update
  String toCreateJson() => json.encode(toCreateMap());

  /// JSON Decode untuk 1 object
  factory EssConfigOvertime.fromJson(String source) =>
      EssConfigOvertime.fromMap(json.decode(source));

  /// JSON Encode untuk 1 object
  String toJson() => json.encode(toMap());

  /// Parse dari JSON array (response getAllConfigs)
  static List<EssConfigOvertime> fromJsonList(String source) {
    final data = json.decode(source);
    final list = data['data'] as List<dynamic>;
    return list.map((e) => EssConfigOvertime.fromMap(e)).toList();
  }
}
