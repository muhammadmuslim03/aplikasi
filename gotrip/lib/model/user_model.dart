class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final String?
  password;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email, 'password': password};
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'pendaki',
    );
  }
}
