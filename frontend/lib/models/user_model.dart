class User {
  final String id;
  final String email;
  final String username;
  final String gender;
  final String birthDate;
  final String phoneNumber;
  final String nationality;
  final String passport_nation;
  final String passport_expiration;
  final int score;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.gender,
    required this.birthDate,
    required this.phoneNumber,
    required this.nationality,
    required this.passport_nation,
    required this.passport_expiration,
    required this.score,
  });

  // Convert JSON to User instance
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] != null ? json['id'].toString() : 'Unknown id',
      email: json['email'] ?? 'Unknown Email',
      username: json['username'] ?? 'Unknown Username',
      gender: json['gender'] ?? 'Unknown Gender',
      birthDate: json['birthdate'] != null ? json['birthdate'].toString() : 'Unknown Birthdate',
      phoneNumber: json['phone_number'] ?? 'Unknown Phone number',
      nationality: json['nationality'] ?? 'Unknown Nationality',
      passport_nation: json['passport_nation'] ?? 'Unknown nation',
      passport_expiration: json['passport_expiration'] ?? 'Unknown expiration',
      score: json['score'] ?? 0,
    );
  }

  // Convert User instance to JSON
  Map<String, dynamic> toJson() {
    // print(this.birthDate);
    return {
      "id": this.id,
      "email": this.email == 'Unknown Email' ? null : this.email,
      "username": this.username == 'Unknown Username' ? null : this.username,
      "gender": this.gender == 'Unknown Gender' ? null : this.gender,
      "birthDate": this.birthDate == 'Unknown Birthdate' ? null : this.birthDate,
      "phoneNumber": this.phoneNumber == 'Unknown Phone number' ? null : this.phoneNumber,
      "nationality": this.nationality == 'Unknown Nationality' ? null : this.nationality,
      // "passport_id": this.passport_id == 'Unknown Passport id' ? null : this.passport_id,
      "passport_nation": this.passport_nation == 'Unknown nation' ? null : this.passport_nation,
      "passport_expiration": this.passport_expiration == 'Unknown expiration' ? null : this.passport_expiration,
      "score": this.score,
    };
  }
}