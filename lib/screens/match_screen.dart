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
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
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
            title: Text('${match.player1Name} vs ${match.player2Name}'),
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
              _buildScoreBoard(context, match),
              const Divider(height: 1),
              _buildControlHeader(context, match),
              Expanded(
                child: _buildPlayingField(context, match),
              ),
              _buildActionButtons(context, match),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlHeader(BuildContext context, TennisMatch match) {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<MatchBloc>().add(UndoLastPoint(widget.matchId));
              _resetFaultStatus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[500],
            ),
            child: const Text('UNDO'),
          ),
          Text(
            _formatTime(_seconds),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Options menu
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[500],
            ),
            child: const Text('OPTIONS'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingField(BuildContext context, TennisMatch match) {
    final servingPlayerName = match.servingPlayer == 1
        ? match.player1Name
        : match.player2Name;
    final receivingPlayerName = match.servingPlayer == 1
        ? match.player2Name
        : match.player1Name;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${match.currentGameScoreDisplay}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        receivingPlayerName,
                        style: const TextStyle(fontSize: 18),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.add, size: 32),
                      ),
                      Text(
                        servingPlayerName,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TennisMatch match) {
    final player1ButtonColor = match.servingPlayer == 1
        ? Colors.lightGreen
        : Colors.lightBlue;
    final player2ButtonColor = match.servingPlayer == 2
        ? Colors.lightGreen
        : Colors.lightBlue;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // NET logic - counts as fault
                  if (_isFirstFault) {
                    setState(() {
                      _isFirstFault = false;
                    });
                  } else {
                    // Double fault - point to receiver
                    final receivingPlayer = match.servingPlayer == 1 ? 2 : 1;
                    context.read<MatchBloc>().add(AddPoint(widget.matchId, receivingPlayer));
                    _startTimer();
                    _resetFaultStatus();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('NET'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // ACE - point to server
                  context.read<MatchBloc>().add(AddPoint(widget.matchId, match.servingPlayer));
                  _startTimer();
                  _resetFaultStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('ACE'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // FAULT/DBLFLT logic
                  if (_isFirstFault) {
                    setState(() {
                      _isFirstFault = false;
                    });
                  } else {
                    // Double fault - point to receiver
                    final receivingPlayer = match.servingPlayer == 1 ? 2 : 1;
                    context.read<MatchBloc>().add(AddPoint(widget.matchId, receivingPlayer));
                    _startTimer();
                    _resetFaultStatus();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isFirstFault ? 'FAULT' : 'DBLFLT'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // FTFLT (foot fault) - counts as first fault
                  setState(() {
                    _isFirstFault = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('FTFLT'),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<MatchBloc>().add(AddPoint(widget.matchId, 1));
                  _startTimer();
                  _resetFaultStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: player1ButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                ),
                child: Text(
                  match.player1Name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<MatchBloc>().add(AddPoint(widget.matchId, 2));
                  _startTimer();
                  _resetFaultStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: player2ButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                ),
                child: Text(
                  match.player2Name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreBoard(BuildContext context, TennisMatch match) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 100),
              ...List.generate(
                match.sets.length,
                    (index) => Expanded(
                  child: Text(
                    'Set ${index + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 100),
            ],
          ),
          const SizedBox(height: 8),
          _buildPlayerScoreRow(context, match, 1),
          const SizedBox(height: 4),
          _buildPlayerScoreRow(context, match, 2),
          const SizedBox(height: 16),
          Text(
            'Score actuel: ${match.currentGameScoreDisplay}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (match.isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'MATCH TERMINÉ - ${match.winner == 1 ? match.player1Name : match.player2Name} GAGNANT',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreRow(BuildContext context, TennisMatch match, int playerNum) {
    final playerName = playerNum == 1 ? match.player1Name : match.player2Name;
    final isServing = match.servingPlayer == playerNum;

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Row(
            children: [
              if (isServing)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.sports_tennis, size: 16),
                ),
              Expanded(
                child: Text(
                  playerName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isServing ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(
          match.sets.length,
              (index) {
            final setScore = match.sets[index];
            final playerScore = playerNum == 1 ? setScore.player1Games : setScore.player2Games;
            final tiebreakScore = playerNum == 1 ? setScore.player1TiebreakPoints : setScore.player2TiebreakPoints;

            return Expanded(
              child: Text(
                setScore.inTiebreak && tiebreakScore > 0
                    ? '$playerScore ($tiebreakScore)'
                    : '$playerScore',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              playerNum == 1 ? match.player1SetsWon : match.player2SetsWon,
                  (index) => const Icon(Icons.circle, size: 12, color: Colors.green),
            ),
          ),
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
          'Êtes-vous sûr de vouloir terminer le match entre ${match.player1Name} et ${match.player2Name}?',
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