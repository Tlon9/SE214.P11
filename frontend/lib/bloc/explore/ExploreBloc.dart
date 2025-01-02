import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelowkey/bloc/explore/ExploreEvent.dart';
import 'package:travelowkey/bloc/explore/ExploreState.dart';
import 'package:travelowkey/models/area_model.dart';
import 'package:travelowkey/models/flight_model.dart';
import 'package:travelowkey/models/hotel_model.dart';
import 'package:travelowkey/repositories/exploreResult_repository.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final ExploreRepository repository;
  final String queryArea;
  ExploreBloc({required this.repository, required this.queryArea}) : super(ExploreLoading()) {
    on<FetchHotels>(_onFetchFlightsAndHotels);
  }

  Future<void> _onFetchFlightsAndHotels(FetchHotels event, Emitter<ExploreState> emit) async {
    emit(ExploreLoading());

    try {
      // Fetch both hotels and flights
      final results = await repository.fetchHotels(queryArea: event.queryArea);
      final hotels = results['hotels'] as List<Hotel>;
      final flights = results['flights'] as List<Flight>;
      final areas = results['areas'] as List<Area>;

      emit(ExploreLoaded(hotels, flights, areas));
    } catch (e) {
      emit(ExploreError("Failed to fetch hotels."));
    }
  }
}
