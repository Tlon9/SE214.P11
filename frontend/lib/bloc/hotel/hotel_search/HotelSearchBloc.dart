// Hotel_search_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/hotel/hotel_search/HotelSearchEvent.dart';
import 'package:travelowkey/bloc/hotel/hotel_search/HotelSearchState.dart';
import 'package:travelowkey/repositories/hotelSearch_repository.dart';

class HotelSearchBloc extends Bloc<HotelSearchEvent, HotelSearchState> {
  final HotelSearchRepository repository;

  HotelSearchBloc({required this.repository}) : super(HotelSearchInitial()) {
    on<LoadHotelSearchData>((event, emit) async {
      emit(HotelSearchLoading());
      try {
        final data = await repository.getHotelSearchData();
        emit(HotelSearchDataLoaded(
            areas: data.areas, customerCounts: data.customerCounts));
      } catch (e) {
        emit(HotelSearchInitial()); // handle error state if needed
      }
    });

    on<SelectArea>((event, emit) {
      final currentState = state as HotelSearchDataLoaded;
      emit(currentState.copyWith(selectedArea: event.area));
    });

    on<SelectCustomerCount>((event, emit) {
      final currentState = state as HotelSearchDataLoaded;
      emit(currentState.copyWith(selectedCustomerCount: event.customerCount));
    });

    on<SelectCheckInDate>((event, emit) {
      final currentState = state as HotelSearchDataLoaded;
      emit(currentState.copyWith(selectedCheckInDate: event.checkinDate));
    });
    on<SelectCheckOutDate>((event, emit) {
      final currentState = state as HotelSearchDataLoaded;
      emit(currentState.copyWith(selectedCheckOutDate: event.checkoutDate));
    });
  }
}
