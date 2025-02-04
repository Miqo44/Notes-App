import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/notes_bloc.dart';
import 'bloc/notes_event.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc()..add(LoadNotes()),
      child: MaterialApp(
        title: 'Заметки',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color.fromRGBO(37, 37, 37, 1),
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'Nunito',
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
