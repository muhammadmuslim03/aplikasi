class UserModel {
  final String id; // UUID dari DB
  final String name; // Nama lengkap pendaki
  final String email;
  final String? phone;
  final String? NIK; // NIK/Paspor
  final String role; // 'pendaki' | 'admin'
  final bool checkIn;
  final bool checkOut;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.NIK,
    required this.role,
    this.checkIn = false,
    this.checkOut = false,
    this.checkInAt,
    this.checkOutAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      NIK: json['NIK'],
      role: json['role'] ?? 'pendaki',
      checkIn: json['check_in'] ?? false,
      checkOut: json['check_out'] ?? false,
      checkInAt: DateTime.tryParse(json['check_in_at'] ?? ''),
      checkOutAt: DateTime.tryParse(json['check_out_at'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'NIK': NIK,
      'role': role,
      'check_in': checkIn,
      'check_out': checkOut,
      'check_in_at': checkInAt?.toIso8601String(),
      'check_out_at': checkOutAt?.toIso8601String(),
    };
  }
}
