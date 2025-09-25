import 'dart:convert';

class EssConfigOvertime {
  final String id;
  final double monthlyTotalDurationHours;
  final int restTimeMinutes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EssConfigOvertime({
    required this.id,
    required this.monthlyTotalDurationHours,
    required this.restTimeMinutes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// CopyWith agar bisa update sebagian field
  EssConfigOvertime copyWith({
    String? id,
    double? monthlyTotalDurationHours,
    int? restTimeMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EssConfigOvertime(
      id: id ?? this.id,
      monthlyTotalDurationHours:
          monthlyTotalDurationHours ?? this.monthlyTotalDurationHours,
      restTimeMinutes: restTimeMinutes ?? this.restTimeMinutes,
      isActive: isActive ?? this.isActive,
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
      isActive: map['is_active'] ?? true, // ambil dari API
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  /// Konversi ke Map penuh (debug)
  Map<String, dynamic> toMap() {
    return {
      'config_overtime_id': id,
      'monthly_total_duration_hours': monthlyTotalDurationHours,
      'rest_time_minutes': restTimeMinutes,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Map khusus Create/Update
  Map<String, dynamic> toCreateMap() {
    return {
      'monthly_total_duration_hours': monthlyTotalDurationHours,
      'rest_time_minutes': restTimeMinutes,
    };
  }

  /// Map khusus update isActive
  Map<String, dynamic> toUpdateIsActiveMap() {
    return {
      'is_active': isActive,
    };
  }

  /// JSON Encode untuk Create/Update
  String toCreateJson() => json.encode(toCreateMap());

  /// JSON Encode untuk update isActive
  String toUpdateIsActiveJson() => json.encode(toUpdateIsActiveMap());


  factory EssConfigOvertime.fromJson(String source) =>
      EssConfigOvertime.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  static List<EssConfigOvertime> fromJsonList(String source) {
    final data = json.decode(source);
    final list = data['data'] as List<dynamic>;
    return list.map((e) => EssConfigOvertime.fromMap(e)).toList();
  }
}


