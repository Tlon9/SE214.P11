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
    String? nationality,
    String? passport_nation,
    String? passport_expiration,
    int? score
  }) {
    return UserProfileLoaded(
      User(
        id: user.id,
        username: username ?? user.username,
        gender: gender ?? user.gender,
        phoneNumber: phoneNumber ?? user.phoneNumber,
        email: email ?? user.email,
        birthDate: birthDate ?? user.birthDate,
        nationality: nationality?? user.nationality,
        passport_nation: passport_nation ?? user.passport_nation,
        passport_expiration: passport_expiration ?? user.passport_expiration,
        score: score ?? user.score,
      )
    );
  }

  User copyWithUser({
    String? username,
    String? gender,
    String? phoneNumber,
    String? email,
    String? birthDate,
    String? nationality,
    String? passport_nation,
    String? passport_expiration,
    int? score,
  }) {
    return User(
        id: user.id,
        username: username ?? user.username,
        gender: gender ?? user.gender,
        phoneNumber: phoneNumber ?? user.phoneNumber,
        email: email ?? user.email,
        birthDate: birthDate ?? user.birthDate,
        nationality: nationality ?? user.nationality,
        passport_nation: passport_nation ?? user.passport_nation,
        passport_expiration: passport_expiration ?? user.passport_expiration,
        score: score ?? user.score
      );
  }

  @override
  List<Object> get props => [user];
}