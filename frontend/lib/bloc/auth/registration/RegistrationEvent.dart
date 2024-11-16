import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterButtonPressed extends RegistrationEvent {
  final String email;
  final String fullname;
  final String password;

  RegisterButtonPressed({required this.email, required this.fullname, required this.password});

  @override
  List<Object> get props => [email, fullname, password];
}

class SignInWithGoogle extends RegistrationEvent {}