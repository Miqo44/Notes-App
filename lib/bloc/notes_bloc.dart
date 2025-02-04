import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes_event.dart';
import 'notes_state.dart';
import '../models/note_model.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final List<Note> _notes = [];
  List<Note> _allNotes = [];

  NotesBloc() : super(NotesLoading()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<SearchNotes>(_onSearchNotes);
    on<ToggleSearch>(_onToggleSearch);
  }

  void _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) {
    _allNotes = List.from(_notes);
    emit(NotesLoaded(List.from(_notes)));
  }

  void _onAddNote(AddNote event, Emitter<NotesState> emit) {
    _notes.add(event.note);
    _allNotes = List.from(_notes);
    emit(NotesLoaded(List.from(_notes)));
  }

  void _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) {
    final index = _notes.indexWhere((note) => note.id == event.note.id);
    if (index != -1) {
      _notes[index] = event.note;
      _allNotes = List.from(_notes);
      emit(NotesLoaded(List.from(_notes)));
    }
  }

  void _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) {
    _notes.removeWhere((note) => note.id == event.id);
    _allNotes = List.from(_notes);
    emit(NotesLoaded(List.from(_notes)));
  }

  void _onSearchNotes(SearchNotes event, Emitter<NotesState> emit) {
    final query = event.query.toLowerCase();
    final filteredNotes = _allNotes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();

    emit(NotesLoaded(filteredNotes, isSearching: true));
  }

  void _onToggleSearch(ToggleSearch event, Emitter<NotesState> emit) {
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      emit(NotesLoaded(currentState.notes, isSearching: event.isSearching));
    }
  }

}
