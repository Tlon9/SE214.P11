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

class SelectExpirationDate extends UserProfileEvent {
  final String passport_expiration;
  SelectExpirationDate(this.passport_expiration);

  @override
  List<Object?> get props => [passport_expiration];
}

class UpdateUserProfile extends UserProfileEvent {
  final String? username;
  final String? gender;
  final String? phoneNumber;
  final String? email;
  final String? birthDate;
  final String? nationality;
  final String? passport_nation;
  final String? passport_expiration;

  UpdateUserProfile({
    this.username,
    this.gender,
    this.phoneNumber,
    this.email,
    this.birthDate,
    this.nationality,
    this.passport_nation,
    this.passport_expiration
  });
}