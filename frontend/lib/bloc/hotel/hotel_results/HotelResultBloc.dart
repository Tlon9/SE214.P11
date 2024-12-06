import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_registration/bloc/hotel/hotel_results/HotelResultEvent.dart';
import 'package:user_registration/bloc/hotel/hotel_results/HotelResultState.dart';
import 'package:user_registration/repositories/hotelResult_repository.dart';
// import 'package:user_registration/models/hotel_model.dart';

class HotelResultBloc extends Bloc<HotelResultEvent, HotelResultState> {
  final HotelResultRepository repository;

  HotelResultBloc({required this.repository}) : super(HotelResultInitial()) {
    on<LoadHotelResults>(_onLoadHotelResults);
    on<ApplyFilter>(_onApplyFilter);
    on<ApplySort>(_onApplySort);
    on<LoadMoreHotels>(_onLoadMoreHotels);
  }

  Future<void> _onLoadHotelResults(LoadHotelResults event, Emitter<HotelResultState> emit) async {
    // final currentState = state as HotelResultLoaded;
    emit(HotelResultLoading());
    try {
      final hotels = await repository.fetchHotels(
          offset: 0,  // Reset offset on sort change
          limit: 5,   // Fetch 5 items on sort change
          searchInfo: event.searchInfo,
      );
      // print(hotels);
      emit(HotelResultLoaded(hotels: hotels, offset: 5));
    } catch (e) {
      emit(HotelResultError(e.toString()));
    }
  }
  // Handle the LoadMoreHotels event to load 5 more items
  Future<void> _onLoadMoreHotels(LoadMoreHotels event, Emitter<HotelResultState> emit) async {
    if (state is HotelResultLoaded) {
      final currentState = state as HotelResultLoaded;
      // emit(HotelResultLoading());
      try {
        // print(currentState.offset!);
        final allHotels = await repository.fetchHotels(
          searchInfo: event.searchInfo,
          offset: currentState.offset!,  // Pass the current offset
          limit: 5,  // Fetch only 5 more items
        );
        // print(currentState.offset!);
        // final allHotels = List<Hotel>.from(currentState.hotels)..addAll(moreHotels);
        // print(allHotels.length);
        emit(HotelResultLoaded(
          hotels: allHotels,
          filterOption: currentState.filterOption,
          sortOption: currentState.sortOption,
          offset: allHotels.length,  // Update the offset for next load
        ));
      } catch (e) {
        emit(HotelResultError(e.toString()));
      }
    }
  }

  Future<void> _onApplyFilter( ApplyFilter event, Emitter<HotelResultState> emit) async {
    if (state is HotelResultLoaded) {
      final currentState = state as HotelResultLoaded;
      emit(HotelResultLoading());
      try {
        final hotels = await repository.fetchHotels(
          searchInfo: event.searchInfo,
          filterOption: event.filterOption,
          sortOption: currentState.sortOption,
          offset: 0,  // Reset offset on filter change
          limit: 5,   // Fetch 5 items on filter change
        );
        emit(HotelResultLoaded(
          hotels: hotels,
          filterOption: event.filterOption,
          sortOption: currentState.sortOption,
          offset: 5
        ));
      } catch (e) {
        emit(HotelResultError(e.toString()));
      }
    }
  }

  Future<void> _onApplySort(ApplySort event, Emitter<HotelResultState> emit) async {
    if (state is HotelResultLoaded) {
      final currentState = state as HotelResultLoaded;
      emit(HotelResultLoading());
      try {
        final hotels = await repository.fetchHotels(
          searchInfo: event.searchInfo,
          filterOption: currentState.filterOption,
          sortOption: event.sortOption,
          offset: 0,  // Reset offset on filter change
          limit: 5,   // Fetch 5 items on filter change
        );
        emit(HotelResultLoaded(
          hotels: hotels,
          filterOption: currentState.filterOption,
          sortOption: event.sortOption,
          offset: 5
        ));
      } catch (e) {
        emit(HotelResultError(e.toString()));
      }
    }
  }
}
