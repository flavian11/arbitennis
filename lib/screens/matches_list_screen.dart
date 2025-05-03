import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/match_bloc.dart';
import '../models/tennis_match.dart';
import 'match_setup_screen.dart';
import 'match_screen.dart';

class MatchesListScreen extends StatelessWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArbiTennis'),
        centerTitle: true,
      ),
      body: BlocBuilder<MatchBloc, MatchState>(
        builder: (context, state) {
          if (state.matches.isEmpty) {
            return const Center(
              child: Text(
                'Aucun match enregistré.\nAppuyez sur + pour créer un match.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: state.matches.length,
            itemBuilder: (context, index) {
              final match = state.matches[index];
              return MatchListTile(match: match);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MatchSetupScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MatchListTile extends StatelessWidget {
  final TennisMatch match;

  const MatchListTile({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text('${match.player1Name} vs ${match.player2Name}'),
        subtitle: Text(
          match.isCompleted
              ? 'Match terminé - Score final: ${match.scoreDisplay}'
              : 'Match en cours - ${match.tournamentName}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.sports_tennis),
          onPressed: () {
            context.read<MatchBloc>().add(LoadMatch(match.id));
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MatchScreen(matchId: match.id),
              ),
            );
          },
        ),
      ),
    );
  }
}