import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {}

class SelectBirthDate extends UserProfileEvent {
  final String birthDate;
  SelectBirthDate(this.birthDate);

  @override
  List<Object?> get props => [birthDate];
}

class UpdateUserProfile extends UserProfileEvent {
  final String? username;
  final String? gender;
  final String? phoneNumber;
  final String? email;
  final String? birthDate;

  UpdateUserProfile({
    this.username,
    this.gender,
    this.phoneNumber,
    this.email,
    this.birthDate,
  });
}
