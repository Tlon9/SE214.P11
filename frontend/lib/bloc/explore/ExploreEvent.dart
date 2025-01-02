import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object> get props => [];
}

class FetchHotels extends ExploreEvent {
  final String? queryArea;

  FetchHotels({this.queryArea});
}
