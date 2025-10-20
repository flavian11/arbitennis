import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/match_bloc.dart';
import '../models/player.dart';
import 'match_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _player1NameController = TextEditingController();
  final _player1RankingController = TextEditingController();
  final _player1CountryController = TextEditingController();

  final _player2NameController = TextEditingController();
  final _player2RankingController = TextEditingController();
  final _player2CountryController = TextEditingController();

  final _tournamentController = TextEditingController();

  @override
  void dispose() {
    _player1NameController.dispose();
    _player1RankingController.dispose();
    _player1CountryController.dispose();
    _player2NameController.dispose();
    _player2RankingController.dispose();
    _player2CountryController.dispose();
    _tournamentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Création de Match'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Joueur 1',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _player1NameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du joueur 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _player1RankingController,
                    decoration: const InputDecoration(
                      labelText: 'Classement (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _player1CountryController,
                    decoration: const InputDecoration(
                      labelText: 'Pays (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Joueur 2',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _player2NameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du joueur 2';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _player2RankingController,
                    decoration: const InputDecoration(
                      labelText: 'Classement (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _player2CountryController,
                    decoration: const InputDecoration(
                      labelText: 'Pays (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _tournamentController,
              decoration: const InputDecoration(
                labelText: 'Tournoi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du tournoi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final matchId = DateTime.now().millisecondsSinceEpoch.toString();

                  final player1 = Player.create(
                    name: _player1NameController.text,
                    ranking: _player1RankingController.text.isNotEmpty
                        ? int.tryParse(_player1RankingController.text)
                        : null,
                    country: _player1CountryController.text.isNotEmpty
                        ? _player1CountryController.text
                        : null,
                  );

                  final player2 = Player.create(
                    name: _player2NameController.text,
                    ranking: _player2RankingController.text.isNotEmpty
                        ? int.tryParse(_player2RankingController.text)
                        : null,
                    country: _player2CountryController.text.isNotEmpty
                        ? _player2CountryController.text
                        : null,
                  );

                  context.read<MatchBloc>().add(
                    CreateMatch(
                      matchId: matchId,
                      player1: player1,
                      player2: player2,
                      tournamentName: _tournamentController.text,
                      leftPlayer: 1,
                    ),
                  );

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MatchScreen(matchId: matchId),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'COMMENCER LE MATCH',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}