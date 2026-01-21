class UserModel {
  String? id;
  String? username;
  String? profileimg;
  String? email;
  String? mobile;
  String? otp;
  String? isOtpVerified;
  String? walletBalance;
  String? active;
  String? fcmId;
  String? appLoginToken;
  String? socialId;
  String? socialType;
  String? socialData;
  String? created;
  String? modified;
  String? referalId;
  String? referalCode;

  UserModel({
    this.id,
    this.username,
    this.profileimg,
    this.email,
    this.referalId,
    this.referalCode,
    this.mobile,
    this.otp,
    this.isOtpVerified,
    this.walletBalance,
    this.active,
    this.fcmId,
    this.appLoginToken,
    this.socialId,
    this.socialType,
    this.socialData,
    this.created,
    this.modified,
  });

  /// ✅ This will map only profile_details part
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? "",
      username: json['username'] ?? "",
      profileimg: json['profileimg'] ?? "",
      email: json['email'] ?? "",
      mobile: json['mobile'] ?? "",
      otp: json['otp'] ?? "",
      isOtpVerified: json['is_otp_verified'] ?? "",
      walletBalance: json['wallet_balance']?.toString() ?? "",
      active: json['active'] ?? "",
      fcmId: json['fcm_id'] ?? "",
      appLoginToken: json['app_login_token'] ?? "",
      socialId: json['social_id'] ?? "",
      socialType: json['social_type'] ?? "",
      socialData: json['social_data'] ?? "",
      created: json['created'] ?? "",
      modified: json['modified'] ?? "",
      referalId: json['referal_id'] ?? "",
      referalCode: json['referal_code'] ?? "",
    );
  }

  /// ✅ Use this when response contains { "profile_details": {...} }
  factory UserModel.fromProfileResponse(Map<String, dynamic> json) {
    return UserModel.fromJson(json['profile_details'] ?? {});
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "profileimg": profileimg,
      "email": email,
      "mobile": mobile,
      "otp": otp,
      "is_otp_verified": isOtpVerified,
      "wallet_balance": walletBalance,
      "active": active,
      "fcm_id": fcmId,
      "app_login_token": appLoginToken,
      "social_id": socialId,
      "social_type": socialType,
      "social_data": socialData,
      "created": created,
      "modified": modified,
      "referal_id": referalId,
      "referal_code": referalCode,
    };
  }
}
