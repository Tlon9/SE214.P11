import 'package:equatable/equatable.dart';
import 'package:user_registration/models/user_model.dart';

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

  @override
  List<Object> get props => [user];
}