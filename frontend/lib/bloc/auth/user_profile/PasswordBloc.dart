import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/auth/user_profile/PasswordEvent.dart';
import 'package:travelowkey/bloc/auth/user_profile/PasswordState.dart';
import 'package:travelowkey/repositories/userProfile_repository.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, PasswordState> {
  final PasswordRepository repository;

  ChangePasswordBloc({required this.repository}) : super(PasswordInitial()) {

    on<LoadPassword>(_onLoadPassword);

    on<UpdatePassword>((event, emit) async {
      if (state is PasswordLoaded) {
            final currentState = state as PasswordLoaded;

            // Create updated User instance
            final updatedPassword = currentState.copyWithPassword(
              oldPassword: event.oldPassword,
              newPassword: event.newPassword,
            );

            try {
              // Call the repository to update user info
              await repository.updatePassword(updatedPassword);

              // Emit the updated state
              // emit(PasswordSuccess());
              event.onSuccess?.call();
            } catch (e) {
              // emit(PasswordFailure('Failed to update user info: $e'));
              event.onFailure?.call('Failed to update password: $e');
            }
      }
    });
  }
  Future<void> _onLoadPassword(LoadPassword event, Emitter<PasswordState> emit) async {
      // final currentState = state as HotelResultLoaded;
      emit(PasswordLoading());
      try {
        emit(PasswordLoaded());
      } catch (e) {
        emit(PasswordFailure(e.toString()));
      }
    }
}
