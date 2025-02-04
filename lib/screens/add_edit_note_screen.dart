import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app1/bloc/notes_event.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_state.dart';
import '../models/note_model.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  AddEditNoteScreenState createState() => AddEditNoteScreenState();
}

class AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_isEdited) {
      setState(() {
        _isEdited = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onBackPressed();
          if (context.mounted && shouldPop) {
            Navigator.of(context).pop(result);
          }
        }
      },
      child: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesLoaded) {
            _titleController.clear();
            _contentController.clear();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            title: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Color.fromRGBO(59, 59, 59, 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () async {
                  final shouldPop = await _onBackPressed();
                  if (context.mounted && shouldPop) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(59, 59, 59, 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.save, color: Colors.white),
                        onPressed: () {
                          if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Both fields must be filled in.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            _onSavePressed();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: Colors.white, fontSize: 35),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: _contentController,
                  style: TextStyle(color: Colors.white, fontSize: 23),
                  decoration: InputDecoration(
                    hintText: 'Type something...',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    final hasChanges = widget.note == null
        ? _titleController.text.isNotEmpty || _contentController.text.isNotEmpty
        : _titleController.text != widget.note!.title || _contentController.text != widget.note!.content;

    if (hasChanges) {
      final result = await _showDiscardDialog();
      return result ?? false;
    }
    return true;
  }

  void _onSavePressed() {
    if (widget.note != null && _isEdited) {
      _showSaveDialog();
    } else {
      _saveNote();
    }
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty && content.isNotEmpty) {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().toString(),
        title: title,
        content: content,
      );
      if (widget.note == null) {
        context.read<NotesBloc>().add(AddNote(note));
      } else {
        context.read<NotesBloc>().add(UpdateNote(note));
      }
      _titleController.clear();
      _contentController.clear();
      Navigator.pop(context, true);
    }
  }

  Future<void> _showSaveDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(Icons.info, color: Colors.white, size: 36),
        content: Text(
          'Save changes?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Color.fromRGBO(37, 37, 37, 1),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Discard', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _saveNote();
                },
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDiscardDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(Icons.info, color: Colors.white, size: 36),
        content: Text(
          'Are you sure you want to discard your changes?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 23),
        ),
        backgroundColor: Color.fromRGBO(37, 37, 37, 1),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text('Discard', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _saveNote();
                },
                child: Text('Keep', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
