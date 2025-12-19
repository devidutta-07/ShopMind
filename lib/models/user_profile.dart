import 'dart:convert';

class UserProfile {
  String name;
  String email;
  String? phone;
  String? profileImagePath;
  bool isLoggedIn;

  UserProfile({
    this.name = 'Guest User',
    this.email = '',
    this.phone,
    this.profileImagePath = 'web/icons/icon-236.png', // Default Asset
    this.isLoggedIn = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImagePath': profileImagePath,
      'isLoggedIn': isLoggedIn,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Guest User',
      email: map['email'] ?? '',
      phone: map['phone'],
      profileImagePath: map['profileImagePath'] ?? 'web/icons/icon-236.png',
      isLoggedIn: map['isLoggedIn'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
