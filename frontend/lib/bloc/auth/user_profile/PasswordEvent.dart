import 'package:equatable/equatable.dart';

abstract class ChangePasswordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPassword extends ChangePasswordEvent {}


class UpdatePassword extends ChangePasswordEvent {
  final String? oldPassword;
  final String? newPassword;
  final void Function()? onSuccess;
  final void Function(String error)? onFailure;


  UpdatePassword({
    this.oldPassword,
    this.newPassword,
    this.onSuccess,
    this.onFailure,
  });
}