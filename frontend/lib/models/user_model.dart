class User {
  final String email;
  final String accessToken;
  final String refreshToken;

  User({
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  // Convert JSON to User instance
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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