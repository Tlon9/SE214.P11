// flight_search_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_registration/bloc/flight/flight_search/FlightSearchEvent.dart';
import 'package:user_registration/bloc/flight/flight_search/FlightSearchState.dart';
import 'package:user_registration/repositories/flightSearch_repository.dart';

class FlightSearchBloc extends Bloc<FlightSearchEvent, FlightSearchState> {
  final FlightSearchRepository repository;

  FlightSearchBloc({required this.repository}) : super(FlightSearchInitial()) {
    on<LoadFlightSearchData>((event, emit) async {
      emit(FlightSearchLoading());
      try {
        final data = await repository.getFlightSearchData();
        // Debugging: Print the data to the console
        // print("Departures: ${data.departures}");
        // print("Destinations: ${data.destinations}");
        // print("Seat Classes: ${data.seatClasses}");
        // print("Passenger Counts: ${data.passengerCounts}");
        emit(FlightSearchDataLoaded(
          departures: data.departures,
          destinations: data.destinations,
          seatClasses: data.seatClasses,
          passengerCounts: data.passengerCounts,
        ));
      } catch (e) {
        emit(FlightSearchInitial()); // handle error state if needed
      }
    });

    on<SelectDeparture>((event, emit) {
      final currentState = state as FlightSearchDataLoaded;
      emit(currentState.copyWith(selectedDeparture: event.departure));
    });

    on<SelectDestination>((event, emit) {
      final currentState = state as FlightSearchDataLoaded;
      emit(currentState.copyWith(selectedDestination: event.destination));
    });

    on<SelectSeatClass>((event, emit) {
      final currentState = state as FlightSearchDataLoaded;
      emit(currentState.copyWith(selectedSeatClass: event.seatClass));
    });

    on<SelectPassengerCount>((event, emit) {
      final currentState = state as FlightSearchDataLoaded;
      emit(currentState.copyWith(selectedPassengerCount: event.passengerCount));
    });

    on<SelectDepartureDate>((event, emit) {
      final currentState = state as FlightSearchDataLoaded;
      emit(currentState.copyWith(selectedDepartureDate: event.departureDate));
    });
  }
}
