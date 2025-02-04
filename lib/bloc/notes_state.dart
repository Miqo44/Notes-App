import 'package:equatable/equatable.dart';
import '../models/note_model.dart';

abstract class NotesState extends Equatable {
  @override
  List<Object> get props => [];
}

class NotesLoading extends NotesState {}

class NotesEmpty extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final bool isSearching;

  NotesLoaded(this.notes, {this.isSearching = false});

  @override
  List<Object> get props => [List.of(notes), isSearching];
}

class SearchStateChanged extends NotesState {
  final bool isSearching;

  SearchStateChanged(this.isSearching);

  @override
  List<Object> get props => [isSearching];
}


class NotesError extends NotesState {}