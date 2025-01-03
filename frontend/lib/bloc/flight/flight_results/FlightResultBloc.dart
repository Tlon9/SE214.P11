// flight_result_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/flight/flight_results/FlightResultEvent.dart';
import 'package:travelowkey/bloc/flight/flight_results/FlightResultState.dart';
import 'package:travelowkey/repositories/flightResult_repository.dart';

class FlightResultBloc extends Bloc<FlightResultEvent, FlightResultState> {
  final FlightResultRepository repository;

  FlightResultBloc({required this.repository}) : super(FlightResultInitial()) {
    on<LoadFlightResults>(_onLoadFlightResults);
    on<ApplyFilter>(_onApplyFilter);
    on<ApplySort>(_onApplySort);
  }

  Future<void> _onLoadFlightResults(
      LoadFlightResults event, Emitter<FlightResultState> emit) async {
    emit(FlightResultLoading());
    try {
      final flights = await repository.fetchFlights(
        searchInfo: event.searchInfo,
      );
      // print(flights);
      emit(FlightResultLoaded(flights: flights));
    } catch (e) {
      emit(FlightResultError(e.toString()));
    }
  }

  Future<void> _onApplyFilter(
      ApplyFilter event, Emitter<FlightResultState> emit) async {
    if (state is FlightResultLoaded) {
      final currentState = state as FlightResultLoaded;
      emit(FlightResultLoading());
      try {
        final flights = await repository.fetchFlights(
          searchInfo: event.searchInfo,
          filterOption: event.filterOption,
          sortOption: currentState.sortOption,
        );
        emit(FlightResultLoaded(
          flights: flights,
          filterOption: event.filterOption,
          sortOption: currentState.sortOption,
        ));
      } catch (e) {
        emit(FlightResultError(e.toString()));
      }
    }
  }

  Future<void> _onApplySort(
      ApplySort event, Emitter<FlightResultState> emit) async {
    if (state is FlightResultLoaded) {
      final currentState = state as FlightResultLoaded;
      emit(FlightResultLoading());
      try {
        final flights = await repository.fetchFlights(
          searchInfo: event.searchInfo,
          filterOption: currentState.filterOption,
          sortOption: event.sortOption,
        );
        emit(FlightResultLoaded(
          flights: flights,
          filterOption: currentState.filterOption,
          sortOption: event.sortOption,
        ));
      } catch (e) {
        emit(FlightResultError(e.toString()));
      }
    }
  }
}
