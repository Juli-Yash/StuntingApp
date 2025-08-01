// lib/models/user.dart

class User {
  final int? id;
  final String name;
  final String phone;
  final String? email;

  User({this.id, required this.name, required this.phone, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id, 'name': name, 'phone': phone};
    if (email != null) {
      data['email'] = email;
    }
    return data;
  }
}
