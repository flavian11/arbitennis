import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/match_bloc.dart';
import 'screens/matches_list_screen.dart';

void main() {
  runApp(const ArbiTennisApp());
}

class ArbiTennisApp extends StatelessWidget {
  const ArbiTennisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchBloc(),
      child: MaterialApp(
        title: 'Arbitennis',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: const MatchesListScreen(),
      ),
    );
  }
}