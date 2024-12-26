import 'package:equatable/equatable.dart';
import 'package:travelowkey/models/user_model.dart';

abstract class UserProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileSuccess extends UserProfileState {}

class UserProfileFailure extends UserProfileState {
  final String error;

  UserProfileFailure(this.error);

  @override
  List<Object> get props => [error];
}

class UserProfileLoaded extends UserProfileState {
  final User user;

  UserProfileLoaded(this.user);

  UserProfileLoaded copyWith({
    String? username,
    String? gender,
    String? phoneNumber,
    String? email,
    String? birthDate,
  }) {
    return UserProfileLoaded(
      User(
        id: user.id,
        username: username ?? user.username,
        gender: gender ?? user.gender,
        phoneNumber: phoneNumber ?? user.phoneNumber,
        email: email ?? user.email,
        birthDate: birthDate ?? user.birthDate,
        nationality: user.nationality,
        passport_id: user.passport_id,
      )
    );
  }

  User copyWithUser({
    String? username,
    String? gender,
    String? phoneNumber,
    String? email,
    String? birthDate,
  }) {
    return User(
        id: user.id,
        username: username ?? user.username,
        gender: gender ?? user.gender,
        phoneNumber: phoneNumber ?? user.phoneNumber,
        email: email ?? user.email,
        birthDate: birthDate ?? user.birthDate,
        nationality: user.nationality,
        passport_id: user.passport_id,
      );
  }

  @override
  List<Object> get props => [user];
}