import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/auth/user_profile/UserEvent.dart';
import 'package:travelowkey/bloc/auth/user_profile/UserState.dart';
import 'package:travelowkey/repositories/userProfile_repository.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserResultRepository repository;

  UserProfileBloc({required this.repository}) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);

    on<SelectBirthDate>((event, emit) {
      final currentState = state as UserProfileLoaded;
      emit(currentState.copyWith(birthDate: event.birthDate));
    });

    on<UpdateUserProfile>((event, emit) async {
  if (state is UserProfileLoaded) {
        // final currentState = state as UserProfileLoaded;

        // // Create updated User instance
        // final updatedUser = currentState.user.copyWith(
        //   username: event.username,
        //   gender: event.gender,
        //   phoneNumber: event.phoneNumber,
        //   email: event.email,
        //   birthDate: event.birthDate,
        // );

        // try {
        //   // Call the repository to update user info
        //   await repository.updateUser(updatedUser);

        //   // Emit the updated state
        //   emit(UserProfileLoaded(updatedUser));
        // } catch (e) {
        //   emit(UserProfileFailure('Failed to update user info: $e'));
        // }
      }
    });

  }

  Future<void> _onLoadUserProfile(LoadUserProfile event, Emitter<UserProfileState> emit) async {
    // final currentState = state as HotelResultLoaded;
    emit(UserProfileLoading());
    try {
      final user = await repository.fetchUser();
      // print(hotels);
      emit(UserProfileLoaded(user));
    } catch (e) {
      emit(UserProfileFailure(e.toString()));
    }
  }
}
