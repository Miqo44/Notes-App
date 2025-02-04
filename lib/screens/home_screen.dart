import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        bool isSearching = state is NotesLoaded && state.isSearching;
        return Scaffold(
          backgroundColor: Color.fromRGBO(37, 37, 37, 1),
          appBar: isSearching ? _buildSearchAppBar(context) : _buildNormalAppBar(context),
          body: _buildBody(state, isSearching),
          floatingActionButton: isSearching ? null : _buildFAB(context),
        );
      },
    );
  }

  Widget _buildBody(NotesState state, bool isSearching) {
    if (isSearching && _searchController.text.isEmpty) {
      return Container(color: Color.fromRGBO(37, 37, 37, 1));
    } else if (isSearching && state is NotesLoaded && state.notes.isEmpty) {
      return _buildEmptySearchResults();
    } else if (state is NotesLoaded && state.notes.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/Empty_notes.png'),
          SizedBox(
            height: 6,
          ),
          Text(
            'Create your first note !',
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
          )
        ],
      );
    } else if (state is NotesLoaded) {
      final List<Color> tileColors = [
        Color.fromRGBO(255, 158, 158, 1),
        Color.fromRGBO(145, 244, 143, 1),
        Color.fromRGBO(255, 245, 153, 1),
        Color.fromRGBO(158, 255, 255, 1),
        Color.fromRGBO(182, 156, 255, 1),
      ];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 25),
          itemCount: state.notes.length,
          itemBuilder: (context, index) {
            final note = state.notes[index];
            bool isDeleteVisible = false;

            return StatefulBuilder(
              builder: (context, setState) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: isDeleteVisible
                      ? GestureDetector(
                    onTap: () {
                      context.read<NotesBloc>().add(DeleteNote(note.id));
                    },
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10), // Закругление краев
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.delete, color: Colors.white, size: 28),
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      color: tileColors[index % tileColors.length],
                      borderRadius: BorderRadius.circular(10), // Закругление краев
                    ),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(note.title),
                      ),
                      titleTextStyle: TextStyle(fontSize: 25, color: Colors.black),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditNoteScreen(note: note),
                          ),
                        );
                        if (!context.mounted) return;
                        context.read<NotesBloc>().add(LoadNotes());
                      },
                      onLongPress: () {
                        setState(() {
                          isDeleteVisible = true;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } else {
      return Center(child: Text('Ошибка', style: TextStyle(color: Colors.white)));
    }
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(-5, 0),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Color.fromRGBO(37, 37, 37, 1),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<NotesBloc>(),
                child: AddEditNoteScreen(),
              ),
            ),
          );
          if (!context.mounted) return;
          context.read<NotesBloc>().add(LoadNotes());
        },
      ),
    );
  }

  AppBar _buildNormalAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(37, 37, 37, 1),
      title: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Text('Notes',
            style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w600)),
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(59, 59, 59, 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              context.read<NotesBloc>().add(ToggleSearch(true));
              Future.delayed(Duration(milliseconds: 100), () {
                if (!context.mounted) return;
                FocusScope.of(context).requestFocus(_searchFocusNode);
              });
            },
          ),
        ),
        SizedBox(
          width: 21,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 25),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(59, 59, 59, 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  barrierColor: Color.fromRGBO(69, 69, 69, 0.4),
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Color.fromRGBO(37, 37, 37, 1),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 38),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Designed by - ",
                                style: TextStyle(color: Colors.white, fontSize: 15)),
                            Text("Redesigned by - ",
                                style: TextStyle(color: Colors.white, fontSize: 15)),
                            Text("Illustrations - ",
                                style: TextStyle(color: Colors.white, fontSize: 15)),
                            Text("Icons - ", style: TextStyle(color: Colors.white, fontSize: 15)),
                            Text("Font - ", style: TextStyle(color: Colors.white, fontSize: 15)),
                            SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: Text(
                                "Made by ",
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(37, 37, 37, 1),
      title: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(37, 37, 37, 1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: TextStyle(color: Colors.white),
          cursorColor: Color.fromRGBO(204, 204, 204, 1),
          decoration: InputDecoration(
            hintText: 'Search by the keyword...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(25),
            ),
            filled: true,
            fillColor: Color.fromRGBO(59, 59, 59, 1),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            suffixIcon: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                context.read<NotesBloc>().add(ToggleSearch(false));
                context.read<NotesBloc>().add(LoadNotes());
              },
            ),
          ),
          onChanged: (query) {
            setState(() {});
            context.read<NotesBloc>().add(SearchNotes(query));
          },
        ),
      ),
    );
  }

  Widget _buildEmptySearchResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/No_matches_found.png'),
        SizedBox(height: 10),
        Text(
          "File not found. Try searching again.",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 20),
        ),
      ],
    );
  }
}
