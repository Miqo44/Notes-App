import 'package:equatable/equatable.dart';
import '../models/note_model.dart';

abstract class NotesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final Note note;

  AddNote(this.note);

  @override
  List<Object> get props => [note];
}

class UpdateNote extends NotesEvent {
  final Note note;

  UpdateNote(this.note);

  @override
  List<Object> get props => [note];
}

class DeleteNote extends NotesEvent {
  final String id;

  DeleteNote(this.id);

  @override
  List<Object> get props => [id];
}

class SearchNotes extends NotesEvent {
  final String query;

  SearchNotes(this.query);

  @override
  List<Object> get props => [query];
}

class ToggleSearch extends NotesEvent {
  final bool isSearching;

  ToggleSearch(this.isSearching);

  @override
  List<Object> get props => [isSearching];
}