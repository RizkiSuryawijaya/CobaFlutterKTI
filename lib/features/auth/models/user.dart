class User {
  final int id;
  final int nik;   // 👈 ini harus ada biar bisa relasi
  final String name;
  final String email;
  final String? role;

  User({
    required this.id,
    required this.nik,
    required this.name,
    required this.email,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json["id"] ?? 0,
    nik: json["nik"] is int 
        ? json["nik"] 
        : int.tryParse(json["nik"].toString()) ?? 0, 
    name: json["name"] ?? "",
    email: json["email"] ?? "",
    role: json["role"],
  );
}


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nik": nik,
      "name": name,
      "email": email,
      "role": role,
    };
  }
}
