class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String role;
  final String? avatar;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatar: json['avatar'],
    );
  }
}