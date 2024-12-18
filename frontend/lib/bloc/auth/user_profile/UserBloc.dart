import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_registration/bloc/auth/user_profile/UserEvent.dart';
import 'package:user_registration/bloc/auth/user_profile/UserState.dart';
import 'package:user_registration/repositories/userProfile_repository.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserResultRepository repository;

  UserProfileBloc({required this.repository}) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
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
