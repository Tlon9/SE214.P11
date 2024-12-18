class AccountLogin {
  final String email;
  final String accessToken;
  final String refreshToken;

  AccountLogin({
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  // Convert JSON to User instance
  factory AccountLogin.fromJson(Map<String, dynamic> json) {
    return AccountLogin(
      email: json['email'],
      accessToken: json['access'],
      refreshToken: json['refresh'],
    );
  }

  // Convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'access': accessToken,
      'refresh': refreshToken,
    };
  }
}