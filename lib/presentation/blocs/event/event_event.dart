import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:rovify/domain/entities/event.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

class CreateEventRequested extends EventEvent {
  final Event event;
  final File imageFile;

  const CreateEventRequested(this.event, this.imageFile);

  @override
  List<Object> get props => [event, imageFile];
}

class FetchEventsRequested extends EventEvent {}