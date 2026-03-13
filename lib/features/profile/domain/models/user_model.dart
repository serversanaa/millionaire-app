class UserModel {
  final int? id;
  final String fullName;
  final String phone;
  final String? email;
  final String? passwordHash;
  final DateTime? dateOfBirth;
  final String gender;
  final String? profileImageUrl;
  final String? address;
  final int loyaltyPoints;
  final bool vipStatus;
  final DateTime? registrationDate;
  final DateTime? lastLogin;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? authUid;  // يجب إضافته هنا


  UserModel({
    this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.passwordHash,
    this.dateOfBirth,
    this.gender = 'male',
    this.profileImageUrl,
    this.address,
    this.loyaltyPoints = 0,
    this.vipStatus = false,
    this.registrationDate,
    this.lastLogin,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.authUid,

  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      passwordHash: json['password_hash']?.toString(),
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth'].toString()) : null,
      gender: json['gender']?.toString() ?? 'male',
      profileImageUrl: json['profile_image_url']?.toString(),
      address: json['address']?.toString(),
      loyaltyPoints: json['loyalty_points'] is int ? json['loyalty_points'] as int : int.tryParse('${json['loyalty_points']}') ?? 0,
      vipStatus: json['vip_status'] is bool ? json['vip_status'] as bool : '${json['vip_status']}'.toLowerCase() == 'true',
      registrationDate: json['registration_date'] != null ? DateTime.tryParse(json['registration_date'].toString()) : null,
      lastLogin: json['last_login'] != null ? DateTime.tryParse(json['last_login'].toString()) : null,
      isActive: json['is_active'] is bool ? json['is_active'] as bool : '${json['is_active']}'.toLowerCase() == 'true',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      authUid: json['auth_uid'] != null ? json['auth_uid'].toString() : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password_hash': passwordHash,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'profile_image_url': profileImageUrl,
      'address': address,
      'loyalty_points': loyaltyPoints,
      'vip_status': vipStatus,
      'registration_date': registrationDate?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (authUid != null) 'auth_uid': authUid,

    };
  }
}
