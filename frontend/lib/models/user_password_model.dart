class Password {
  final String oldPassword;
  final String newPassword;

  Password({
    required this.oldPassword,
    required this.newPassword,
  });

  // Convert JSON to User instance
  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      oldPassword: json['password'] != null ? json['password'].toString() : "",
      newPassword: "",
    );
  }

  // Convert User instance to JSON
  Map<String, dynamic> toJson() {
    // print(this.birthDate);
    return {
      "oldPassword": this.oldPassword == "" ? null : this.oldPassword,
      "newPassword": this.newPassword == "" ? null : this.newPassword,
    };
  }
}