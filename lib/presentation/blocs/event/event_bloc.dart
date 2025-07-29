import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/domain/usecases/create_event.dart';
import 'package:rovify/domain/usecases/fetch_events.dart';
import 'package:rovify/presentation/blocs/event/event_event.dart';
import 'package:rovify/presentation/blocs/event/event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final CreateEvent createEventUseCase;
  final FetchEvents fetchEventsUseCase;

  EventBloc({
    required this.createEventUseCase,
    required this.fetchEventsUseCase,
  }) : super(EventInitial()) {
    on<CreateEventRequested>(_onCreateEventRequested);
    on<FetchEventsRequested>(_onFetchEventsRequested);
  }

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventCreating());
    try {
      await createEventUseCase(event.event, event.imageFile);
      emit(EventCreatedSuccessfully());
      add(FetchEventsRequested()); // Refresh event list
    } catch (e) {
      emit(EventError('Failed to create event: $e'));
    }
  }

  Future<void> _onFetchEventsRequested(
    FetchEventsRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final events = await fetchEventsUseCase();
      emit(EventLoaded(events));
    } catch (e) {
      emit(EventError('Failed to fetch events: ${e.toString()}'));
    }
  }
}