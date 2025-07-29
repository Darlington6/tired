import 'package:equatable/equatable.dart';
import 'package:rovify/domain/entities/event.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}

class EventCreating extends EventState {}

class EventCreatedSuccessfully extends EventState {}

class EventLoading extends EventState {} // Added

class EventLoaded extends EventState { // Renamed from EventsLoaded
  final List<Event> events;

  const EventLoaded(this.events);

  @override
  List<Object> get props => [events];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object> get props => [message];
}