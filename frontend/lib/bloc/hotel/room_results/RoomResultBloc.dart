import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/hotel/room_results/RoomResultEvent.dart';
import 'package:travelowkey/bloc/hotel/room_results/RoomResultState.dart';
import 'package:travelowkey/repositories/roomResult_repository.dart';

class RoomResultBloc extends Bloc<RoomResultEvent, RoomResultState> {
  final RoomResultRepository repository;

  RoomResultBloc({required this.repository}) : super(RoomResultInitial()) {
    on<LoadRoomResults>(_onLoadRoomResults);
    on<ApplyFilter>(_onApplyFilter);
    on<ApplySort>(_onApplySort);
  }

  Future<void> _onLoadRoomResults(
      LoadRoomResults event, Emitter<RoomResultState> emit) async {
    emit(RoomResultLoading());
    try {
      final rooms = await repository.fetchRooms(
        searchInfo: event.searchInfo,
      );
      emit(RoomResultLoaded(rooms: rooms));
    } catch (e) {
      print(e.toString());
      emit(RoomResultError(e.toString()));
    }
  }

  Future<void> _onApplyFilter(
      ApplyFilter event, Emitter<RoomResultState> emit) async {
    if (state is RoomResultLoaded) {
      final currentState = state as RoomResultLoaded;
      emit(RoomResultLoading());
      try {
        final rooms = await repository.fetchRooms(
          searchInfo: event.searchInfo,
          filterOption: event.filterOption,
          sortOption: currentState.sortOption,
        );
        emit(RoomResultLoaded(
          rooms: rooms,
          filterOption: event.filterOption,
          sortOption: currentState.sortOption,
        ));
      } catch (e) {
        emit(RoomResultError(e.toString()));
      }
    }
  }

  Future<void> _onApplySort(
      ApplySort event, Emitter<RoomResultState> emit) async {
    if (state is RoomResultLoaded) {
      final currentState = state as RoomResultLoaded;
      emit(RoomResultLoading());
      try {
        final rooms = await repository.fetchRooms(
          searchInfo: event.searchInfo,
          filterOption: currentState.filterOption,
          sortOption: event.sortOption,
        );
        emit(RoomResultLoaded(
          rooms: rooms,
          filterOption: currentState.filterOption,
          sortOption: event.sortOption,
        ));
      } catch (e) {
        emit(RoomResultError(e.toString()));
      }
    }
  }
}
