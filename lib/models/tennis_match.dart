import 'package:arbitennis/models/player.dart';

class TennisMatch {
  final String id;
  final Player player1;
  final Player player2;
  final String tournamentName;
  final List<SetScore> sets;
  final int servingPlayer;
  final int currentGameScore1;
  final int currentGameScore2;
  final bool isCompleted;
  final int winner;
  final List<PointHistoryEntry> pointHistory;
  final int leftPlayer;

  TennisMatch({
    required this.id,
    required this.player1,
    required this.player2,
    required this.tournamentName,
    required this.sets,
    required this.servingPlayer,
    required this.currentGameScore1,
    required this.currentGameScore2,
    required this.isCompleted,
    required this.winner,
    required this.pointHistory,
    required this.leftPlayer,
  });

  factory TennisMatch.create({
    required String matchId,
    required Player player1,
    required Player player2,
    required String tournamentName,
    required int leftPlayer,
  }) {
    return TennisMatch(
      id: matchId,
      player1: player1,
      player2: player2,
      tournamentName: tournamentName,
      sets: [SetScore.newSet()],
      servingPlayer: 1,
      currentGameScore1: 0,
      currentGameScore2: 0,
      isCompleted: false,
      winner: 0,
      pointHistory: [],
      leftPlayer: leftPlayer,
    );
  }

  TennisMatch copyWith({
    String? id,
    Player? player1,
    Player? player2,
    String? tournamentName,
    List<SetScore>? sets,
    int? servingPlayer,
    int? currentGameScore1,
    int? currentGameScore2,
    bool? isCompleted,
    int? winner,
    List<PointHistoryEntry>? pointHistory,
    int? leftPlayer,
  }) {
    return TennisMatch(
      id: id ?? this.id,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      tournamentName: tournamentName ?? this.tournamentName,
      sets: sets ?? this.sets,
      servingPlayer: servingPlayer ?? this.servingPlayer,
      currentGameScore1: currentGameScore1 ?? this.currentGameScore1,
      currentGameScore2: currentGameScore2 ?? this.currentGameScore2,
      isCompleted: isCompleted ?? this.isCompleted,
      winner: winner ?? this.winner,
      pointHistory: pointHistory ?? this.pointHistory,
      leftPlayer: leftPlayer ?? this.leftPlayer,
    );
  }

  int get player1SetsWon => sets.where((set) => set.player1Games > set.player2Games).length;
  int get player2SetsWon => sets.where((set) => set.player2Games > set.player1Games).length;

  int get setsToWin => 2;

  String get scoreDisplay {
    return sets.map((set) {
      if (set.inTiebreak) {
        return '${set.player1Games}-${set.player2Games} [${set.player1TiebreakPoints}-${set.player2TiebreakPoints}]';
      }
      return '${set.player1Games}-${set.player2Games}';
    }).join(', ');
  }

  String get currentGameScoreDisplay {
    final scores = ['0', '15', '30', '40', 'Adv'];

    if (currentGameScore1 == currentGameScore2 && currentGameScore1 >= 3) {
      return 'Égalité';
    } else if (currentGameScore1 >= 4 && currentGameScore1 > currentGameScore2) {
      return 'Ad. ${player1.name}';
    } else if (currentGameScore2 >= 4 && currentGameScore2 > currentGameScore1) {
      return 'Ad. ${player2.name}';
    } else {
      String score1 = "";
      String score2 = "";
      if (servingPlayer == 1) {
         score1 = currentGameScore1 >= scores.length ? scores[scores.length - 1] : scores[currentGameScore1];
         score2 = currentGameScore2 >= scores.length ? scores[scores.length - 1] : scores[currentGameScore2];
      } else {
         score1 = currentGameScore2 >= scores.length ? scores[scores.length - 1] : scores[currentGameScore2];
         score2 = currentGameScore1 >= scores.length ? scores[scores.length - 1] : scores[currentGameScore1];
      }
      return '$score1 - $score2';
    }
  }
}

class SetScore {
  final int player1Games;
  final int player2Games;
  final int player1TiebreakPoints;
  final int player2TiebreakPoints;
  final bool inTiebreak;

  SetScore({
    required this.player1Games,
    required this.player2Games,
    required this.player1TiebreakPoints,
    required this.player2TiebreakPoints,
    required this.inTiebreak,
  });

  factory SetScore.newSet() {
    return SetScore(
      player1Games: 0,
      player2Games: 0,
      player1TiebreakPoints: 0,
      player2TiebreakPoints: 0,
      inTiebreak: false,
    );
  }

  SetScore copyWith({
    int? player1Games,
    int? player2Games,
    int? player1TiebreakPoints,
    int? player2TiebreakPoints,
    bool? inTiebreak,
  }) {
    return SetScore(
      player1Games: player1Games ?? this.player1Games,
      player2Games: player2Games ?? this.player2Games,
      player1TiebreakPoints: player1TiebreakPoints ?? this.player1TiebreakPoints,
      player2TiebreakPoints: player2TiebreakPoints ?? this.player2TiebreakPoints,
      inTiebreak: inTiebreak ?? this.inTiebreak,
    );
  }
}

class PointHistoryEntry {
  final int player;
  final int currentGameScore1;
  final int currentGameScore2;
  final List<SetScore> setScores;
  final int servingPlayer;

  PointHistoryEntry({
    required this.player,
    required this.currentGameScore1,
    required this.currentGameScore2,
    required this.setScores,
    required this.servingPlayer,
  });
}