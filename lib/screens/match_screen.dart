import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/match_bloc.dart';
import '../models/tennis_match.dart';
import 'matches_list_screen.dart';

class MatchScreen extends StatefulWidget {
  final String matchId;

  const MatchScreen({super.key, required this.matchId});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isFirstFault = true;
  int _pointDuration = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _pointDuration = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _pointDuration++;
      });
    });
  }

  void _resetFaultStatus() {
    setState(() {
      _isFirstFault = true;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        final match = state.matches.firstWhere((m) => m.id == widget.matchId);

        return Scaffold(
          appBar: AppBar(
            title: Text('${match.player1.name} vs ${match.player2.name}'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: match.isCompleted
                    ? null
                    : () => _showEndMatchDialog(context, match),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildControlHeader(context, match),
              _buildScoreBoard(context, match),
              const Divider(height: 1, thickness: 2),
              Expanded(
                child: _buildPlayingField(context, match),
              ),
              _buildActionButtons(context, match),
              _buildCurrentScore(context, match),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlHeader(BuildContext context, TennisMatch match) {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                context.read<MatchBloc>().add(UndoLastPoint(widget.matchId));
                _resetFaultStatus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'UNDO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Text(
            _formatTime(_seconds),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                // Options menu
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'OPTIONS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard(BuildContext context, TennisMatch match) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 120),
              ...List.generate(
                3,
                    (index) => Expanded(
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPlayerScoreRow(context, match, 1),
          const SizedBox(height: 4),
          _buildPlayerScoreRow(context, match, 2),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreRow(BuildContext context, TennisMatch match, int playerNum) {
    final playerName = playerNum == 1 ? match.player1.name : match.player2.name;
    final isServing = match.servingPlayer == playerNum;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                playerName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          ...List.generate(
            3,
                (index) {
              if (index < match.sets.length) {
                final setScore = match.sets[index];
                final playerScore = playerNum == 1 ? setScore.player1Games : setScore.player2Games;

                return Expanded(
                  child: Text(
                    '$playerScore',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                );
              } else {
                return Expanded(child: Container());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingField(BuildContext context, TennisMatch match) {
    final leftPlayerName = match.leftPlayer == 1
        ? match.player1.name
        : match.player2.name;
    final rightPlayerName = match.leftPlayer == 1
        ? match.player2.name
        : match.player1.name;

    final isLeftPlayerServing = match.servingPlayer == match.leftPlayer;


    final bool isEvenScore = (match.currentGameScore1 + match.currentGameScore2) % 2 == 0; // Score pair

    return Container(
      color: Colors.white,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Colonne gauche du filet
            SizedBox(
              width: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Partie haute gauche
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: isEvenScore // Si pair, joueur gauche en BAS (donc rien ici)
                          ? Container()
                          : Text( // Si impair, joueur gauche en haut
                        leftPlayerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLeftPlayerServing ? Colors.green[600] : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // Ligne de service
                  Container(height: 4, color: Colors.grey[400]),
                  // Partie basse gauche
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: isEvenScore // Si pair, joueur gauche en bas
                          ? Text(
                        leftPlayerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLeftPlayerServing ? Colors.green[600] : Colors.black,
                        ),
                      )
                          : Container(), // Si impair, rien ici
                    ),
                  ),
                ],
              ),
            ),
            // Filet (ligne verticale au centre)
            Container(
              width: 4,
              height: 204,
              color: Colors.grey[400],
            ),
            // Colonne droite du filet
            SizedBox(
              width: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Partie haute droite
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: isEvenScore // Si pair, joueur droit en haut
                          ? Text(
                        rightPlayerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: !isLeftPlayerServing ? Colors.green[600] : Colors.black,
                        ),
                      )
                          : Container(), // Si impair, rien ici
                    ),
                  ),
                  // Ligne de service
                  Container(height: 4, color: Colors.grey[400]),
                  // Partie basse droite
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: isEvenScore // Si pair, joueur droit en BAS (donc rien ici)
                          ? Container()
                          : Text( // Si impair, joueur droit en bas
                        rightPlayerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: !isLeftPlayerServing ? Colors.green[600] : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScore(BuildContext context, TennisMatch match) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        match.currentGameScoreDisplay,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w300,
          letterSpacing: 8,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TennisMatch match) {
    final player1ButtonColor = match.servingPlayer == 1
        ? Colors.lightGreen[400]
        : Colors.lightBlue[200];
    final player2ButtonColor = match.servingPlayer == 2
        ? Colors.lightGreen[400]
        : Colors.lightBlue[200];

    return Column(
      children: [
        Container(
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _startTimer();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'NET',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    context.read<MatchBloc>().add(AddPoint(widget.matchId, match.servingPlayer));
                    _startTimer();
                    _resetFaultStatus();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'ACE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    if (_isFirstFault) {
                      setState(() {
                        _isFirstFault = false;
                      });
                    } else {
                      final receivingPlayer = match.servingPlayer == 1 ? 2 : 1;
                      context.read<MatchBloc>().add(AddPoint(widget.matchId, receivingPlayer));
                      _startTimer();
                      _resetFaultStatus();
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    _isFirstFault ? 'FAULT' : 'DBLFLT',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isFirstFault = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'FTFLT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<MatchBloc>().add(AddPoint(widget.matchId, match.leftPlayer));
                  _startTimer();
                  _resetFaultStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: player1ButtonColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: Text(
                  match.leftPlayer == 1 ? match.player1.name.toUpperCase() : match.player2.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<MatchBloc>().add(AddPoint(widget.matchId, match.leftPlayer == 1 ? 2 : 1));
                  _startTimer();
                  _resetFaultStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: player2ButtonColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: Text(
                  match.leftPlayer == 1 ? match.player2.name.toUpperCase() : match.player1.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEndMatchDialog(BuildContext context, TennisMatch match) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminer le match?'),
        content: Text(
          'Êtes-vous sûr de vouloir terminer le match entre ${match.player1.name} et ${match.player2.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () {
              context.read<MatchBloc>().add(EndMatch(match.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('TERMINER'),
          ),
        ],
      ),
    );
  }
}