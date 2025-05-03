import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/match_bloc.dart';
import '../models/tennis_match.dart';
import 'match_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  final _tournamentController = TextEditingController();

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
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
            TextFormField(
              controller: _player1Controller,
              decoration: const InputDecoration(
                labelText: 'Joueur 1',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du joueur 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _player2Controller,
              decoration: const InputDecoration(
                labelText: 'Joueur 2',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du joueur 2';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final matchId = DateTime.now().millisecondsSinceEpoch.toString();

                  context.read<MatchBloc>().add(
                    CreateMatch(
                      matchId: matchId,
                      player1Name: _player1Controller.text,
                      player2Name: _player2Controller.text,
                      tournamentName: _tournamentController.text,
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