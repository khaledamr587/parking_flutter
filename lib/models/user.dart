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
    print('User.fromJson called with: $json');
    
    try {
      // Ensure all required fields are present and have proper types
      final safeJson = Map<String, dynamic>.from(json);
      
      // Handle required string fields
      safeJson['email'] = safeJson['email']?.toString() ?? '';
      safeJson['first_name'] = safeJson['first_name']?.toString() ?? '';
      safeJson['last_name'] = safeJson['last_name']?.toString() ?? '';
      safeJson['user_type'] = safeJson['user_type']?.toString() ?? 'user';
      
      // Handle optional string fields
      safeJson['phone'] = safeJson['phone']?.toString();
      safeJson['profile_image'] = safeJson['profile_image']?.toString();
      safeJson['google_id'] = safeJson['google_id']?.toString();
      safeJson['apple_id'] = safeJson['apple_id']?.toString();
      
      // Handle boolean fields
      safeJson['is_email_verified'] = safeJson['is_email_verified'] == true;
      safeJson['is_phone_verified'] = safeJson['is_phone_verified'] == true;
      safeJson['is_active'] = safeJson['is_active'] != false;
      
      // Handle date fields
      DateTime now = DateTime.now();
      try {
        safeJson['created_at'] = safeJson['created_at'] != null 
            ? DateTime.parse(safeJson['created_at'].toString()) 
            : now;
      } catch (e) {
        safeJson['created_at'] = now;
      }
      
      try {
        safeJson['updated_at'] = safeJson['updated_at'] != null 
            ? DateTime.parse(safeJson['updated_at'].toString()) 
            : now;
      } catch (e) {
        safeJson['updated_at'] = now;
      }
      
      return User(
        id: safeJson['id'],
        email: safeJson['email'],
        phone: safeJson['phone'],
        firstName: safeJson['first_name'],
        lastName: safeJson['last_name'],
        profileImage: safeJson['profile_image'],
        googleId: safeJson['google_id'],
        appleId: safeJson['apple_id'],
        isEmailVerified: safeJson['is_email_verified'],
        isPhoneVerified: safeJson['is_phone_verified'],
        userType: safeJson['user_type'],
        createdAt: safeJson['created_at'],
        updatedAt: safeJson['updated_at'],
        isActive: safeJson['is_active'],
      );
    } catch (e) {
      print('Error in User.fromJson: $e');
      print('JSON data: $json');
      rethrow;
    }
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