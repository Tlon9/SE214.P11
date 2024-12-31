import 'package:equatable/equatable.dart';
import 'package:travelowkey/models/user_password_model.dart';

abstract class PasswordState extends Equatable {
  @override
  List<Object> get props => [];
}

class PasswordInitial extends PasswordState {}

class PasswordLoading extends PasswordState {}

class PasswordSuccess extends PasswordState {}

class PasswordFailure extends PasswordState {
  final String error;

  PasswordFailure(this.error);

  @override
  List<Object> get props => [error];
}

// class PasswordLoaded extends PasswordState {
//   final Password password;

//   PasswordLoaded(this.password);

//   PasswordLoaded copyWith({
//     String? oldPassword,
//     String? newPassword
//   }) {
//     return PasswordLoaded(
//       Password(
//         oldPassword: oldPassword ?? password.oldPassword,
//         newPassword: newPassword ?? password.newPassword,
//       )
//     );
//   }

//   Password copyWithPassword({
//     String? oldPassword,
//     String? newPassword
//   }) {
//     return Password(
//         oldPassword: oldPassword ?? password.oldPassword,
//         newPassword: newPassword ?? password.newPassword,
//       );
//   }

//   @override
//   List<Object> get props => [password];
// }
class PasswordLoaded extends PasswordState {
  PasswordLoaded();

  Password copyWithPassword({
    String? oldPassword,
    String? newPassword
  }) {
    return Password(
        oldPassword: oldPassword ?? "",
        newPassword: newPassword ?? "",
      );
  }
}