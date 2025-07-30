class User {
  final int? id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? googleId;
  final String? appleId;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String userType; // 'user', 'admin', 'parking_owner'
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  User({
    this.id,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.googleId,
    this.appleId,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.userType = 'user',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      googleId: json['google_id'],
      appleId: json['apple_id'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? false,
      userType: json['user_type'] ?? 'user',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
      'google_id': googleId,
      'apple_id': appleId,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? profileImage,
    String? googleId,
    String? appleId,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      googleId: googleId ?? this.googleId,
      appleId: appleId ?? this.appleId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get fullName => '$firstName $lastName';
} 