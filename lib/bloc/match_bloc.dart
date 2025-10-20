import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../models/tennis_match.dart';
import '../models/player.dart';

// Events
abstract class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object?> get props => [];
}

class CreateMatch extends MatchEvent {
  final String matchId;
  final Player player1;
  final Player player2;
  final String tournamentName;
  final int leftPlayer;

  const CreateMatch({
    required this.matchId,
    required this.player1,
    required this.player2,
    required this.tournamentName,
    required this.leftPlayer,
  });

  @override
  List<Object?> get props => [
    matchId,
    player1,
    player2,
    tournamentName,
  ];
}

class LoadMatch extends MatchEvent {
  final String matchId;

  const LoadMatch(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class AddPoint extends MatchEvent {
  final String matchId;
  final int player;

  const AddPoint(this.matchId, this.player);

  @override
  List<Object?> get props => [matchId, player];
}

// Implemented from TODO
class AddAce extends MatchEvent {
  final String matchId;
  final int player; // Player who served the ace

  const AddAce(this.matchId, this.player);

  @override
  List<Object?> get props => [matchId, player];
}

// Implemented from TODO
class AddFault extends MatchEvent {
  final String matchId;
  final int player; // Player who made the fault
  final bool isDoubleFault; // If it's a double fault

  const AddFault(this.matchId, this.player, {this.isDoubleFault = false});

  @override
  List<Object?> get props => [matchId, player, isDoubleFault];
}

class UndoLastPoint extends MatchEvent {
  final String matchId;

  const UndoLastPoint(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ToggleServe extends MatchEvent {
  final String matchId;

  const ToggleServe(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class EndMatch extends MatchEvent {
  final String matchId;

  const EndMatch(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

// State
class MatchState extends Equatable {
  final List<TennisMatch> matches;
  final String? currentMatchId;

  const MatchState({required this.matches, this.currentMatchId});

  factory MatchState.initial() {
    return const MatchState(matches: []);
  }

  MatchState copyWith({List<TennisMatch>? matches, String? currentMatchId}) {
    return MatchState(
      matches: matches ?? this.matches,
      currentMatchId: currentMatchId ?? this.currentMatchId,
    );
  }

  @override
  List<Object?> get props => [matches, currentMatchId];
}

// Bloc
class MatchBloc extends Bloc<MatchEvent, MatchState> {
  MatchBloc() : super(MatchState.initial()) {
    on<CreateMatch>(_onCreateMatch);
    on<LoadMatch>(_onLoadMatch);
    on<AddPoint>(_onAddPoint);
    on<AddAce>(_onAddAce);
    on<AddFault>(_onAddFault);
    on<UndoLastPoint>(_onUndoLastPoint);
    on<ToggleServe>(_onToggleServe);
    on<EndMatch>(_onEndMatch);
  }

  void _onCreateMatch(CreateMatch event, Emitter<MatchState> emit) {
    final newMatch = TennisMatch.create(
      matchId: event.matchId,
      player1: event.player1,
      player2: event.player2,
      tournamentName: event.tournamentName,
      leftPlayer: event.leftPlayer,
    );

    final updatedMatches = [...state.matches, newMatch];

    emit(
      state.copyWith(matches: updatedMatches, currentMatchId: event.matchId),
    );
  }

  void _onLoadMatch(LoadMatch event, Emitter<MatchState> emit) {
    emit(state.copyWith(currentMatchId: event.matchId));
  }

  // Helper method to save current point state for history
  PointHistoryEntry _createPointHistoryEntry(TennisMatch match, int scoringPlayer) {
    return PointHistoryEntry(
      player: scoringPlayer,
      currentGameScore1: match.currentGameScore1,
      currentGameScore2: match.currentGameScore2,
      setScores: List.from(match.sets),
      servingPlayer: match.servingPlayer,
    );
  }

  void _onAddPoint(AddPoint event, Emitter<MatchState> emit) {
    final matchIndex = state.matches.indexWhere((m) => m.id == event.matchId);
    if (matchIndex == -1) return;

    final match = state.matches[matchIndex];
    if (match.isCompleted) return;

    // Save the current state for undo functionality
    final currentPointEntry = _createPointHistoryEntry(match, event.player);
    final updatedPointHistory = [...match.pointHistory, currentPointEntry];

    // Current set (last one in the list)
    final currentSetIndex = match.sets.length - 1;
    final currentSet = match.sets[currentSetIndex];

    // Initialize new values
    int newScore1 = match.currentGameScore1;
    int newScore2 = match.currentGameScore2;
    List<SetScore> newSets = List.from(match.sets);
    int leftPlayer = match.leftPlayer;


    // Handle scoring based on whether we're in a tiebreak or regular game
    if (currentSet.inTiebreak) {
      // Tiebreak scoring
      if (event.player == 1) {
        newSets[currentSetIndex] = currentSet.copyWith(
          player1TiebreakPoints: currentSet.player1TiebreakPoints + 1,
        );
      } else {
        newSets[currentSetIndex] = currentSet.copyWith(
          player2TiebreakPoints: currentSet.player2TiebreakPoints + 1,
        );
      }

      // Check change side
      if ((newSets[currentSetIndex].player1TiebreakPoints + newSets[currentSetIndex].player2TiebreakPoints) % 6 == 0) {
        leftPlayer = leftPlayer == 1 ? 2 : 1;
      }

      // Check if tiebreak is won
      final minPointsToWin = 7;
      final player1Points = newSets[currentSetIndex].player1TiebreakPoints;
      final player2Points = newSets[currentSetIndex].player2TiebreakPoints;

      if ((player1Points >= minPointsToWin &&
          player1Points - player2Points >= 2) ||
          (player2Points >= minPointsToWin &&
              player2Points - player1Points >= 2)) {
        // Tiebreak is won
        if (player1Points > player2Points) {
          newSets[currentSetIndex] = newSets[currentSetIndex].copyWith(
            player1Games: currentSet.player1Games + 1,
            inTiebreak: false,
          );
        } else {
          newSets[currentSetIndex] = newSets[currentSetIndex].copyWith(
            player2Games: currentSet.player2Games + 1,
            inTiebreak: false,
          );
        }

        // Check if the set win determines match winner
        bool matchEnded = false;
        int matchWinner = 0;

        final player1SetsWon =
            newSets.where((s) => s.player1Games > s.player2Games).length;
        final player2SetsWon =
            newSets.where((s) => s.player2Games > s.player1Games).length;

        if (player1SetsWon >= match.setsToWin) {
          matchEnded = true;
          matchWinner = 1;
        } else if (player2SetsWon >= match.setsToWin) {
          matchEnded = true;
          matchWinner = 2;
        }

        // Start a new set if match hasn't ended
        if (!matchEnded) {
          newSets.add(SetScore.newSet());
        }

        // Reset game score
        newScore1 = 0;
        newScore2 = 0;

        final updatedMatch = match.copyWith(
          sets: newSets,
          currentGameScore1: newScore1,
          currentGameScore2: newScore2,
          isCompleted: matchEnded,
          winner: matchWinner,
          pointHistory: updatedPointHistory,
        );

        final updatedMatches = [...state.matches];
        updatedMatches[matchIndex] = updatedMatch;

        emit(state.copyWith(matches: updatedMatches));
        return;
      }

      // Change server every two points in tiebreak
      final totalPoints =
          newSets[currentSetIndex].player1TiebreakPoints +
              newSets[currentSetIndex].player2TiebreakPoints;
      if (totalPoints % 2 == 1) {
        final updatedMatch = match.copyWith(
          sets: newSets,
          servingPlayer: match.servingPlayer == 1 ? 2 : 1,
          pointHistory: updatedPointHistory,
        );

        final updatedMatches = [...state.matches];
        updatedMatches[matchIndex] = updatedMatch;

        emit(state.copyWith(matches: updatedMatches));
        return;
      }

      // Just update the tiebreak score
      final updatedMatch = match.copyWith(
        sets: newSets,
        pointHistory: updatedPointHistory,
      );

      final updatedMatches = [...state.matches];
      updatedMatches[matchIndex] = updatedMatch;

      emit(state.copyWith(matches: updatedMatches));
      return;
    }

    // Regular game scoring
    if (event.player == 1) {
      // Player 1 scores a point
      if (newScore1 < 3) {
        // 0, 15, 30 -> next score
        newScore1++;
      } else if (newScore1 == 3 && newScore2 < 3) {
        // 40-0, 40-15, 40-30 -> game won
        newScore1 = 0;
        newScore2 = 0;
        newSets[currentSetIndex] = currentSet.copyWith(
          player1Games: currentSet.player1Games + 1,
        );
      } else if (newScore1 == 3 && newScore2 == 3) {
        // Deuce -> Advantage
        newScore1++;
      } else if (newScore2 == 4 && newScore1 == 3) {
        newScore2--;
      } else if (newScore1 == 4) {
        // Advantage -> game won
        newScore1 = 0;
        newScore2 = 0;
        newSets[currentSetIndex] = currentSet.copyWith(
          player1Games: currentSet.player1Games + 1,
        );
      }
    } else {
      // Player 2 scores a point
      if (newScore2 < 3) {
        // 0, 15, 30 -> next score
        newScore2++;
      } else if (newScore2 == 3 && newScore1 < 3) {
        // 0-40, 15-40, 30-40 -> game won
        newScore1 = 0;
        newScore2 = 0;
        newSets[currentSetIndex] = currentSet.copyWith(
          player2Games: currentSet.player2Games + 1,
        );
      } else if (newScore2 == 3 && newScore1 == 3) {
        // Deuce -> Advantage
        newScore2++;
      } else if (newScore1 == 4 && newScore2 == 3) {
        newScore1--;
      } else if (newScore2 == 4) {
        // Advantage -> game won
        newScore1 = 0;
        newScore2 = 0;
        newSets[currentSetIndex] = currentSet.copyWith(
          player2Games: currentSet.player2Games + 1,
        );

      }
    }

    // Change server after a game
    int newServingPlayer = match.servingPlayer;
    if (newScore1 == 0 &&
        newScore2 == 0 &&
        (newSets[currentSetIndex].player1Games + newSets[currentSetIndex].player2Games > 0)) {
      newServingPlayer = match.servingPlayer == 1 ? 2 : 1;
    }

    // Check if we need to start a tiebreak
    if (currentSet.player1Games == 6 && currentSet.player2Games == 6) {
      newSets[currentSetIndex] = currentSet.copyWith(inTiebreak: true);
    }

    // Check if set is won without tiebreak
    if ((currentSet.player1Games >= 6 &&
        currentSet.player1Games - currentSet.player2Games >= 2) ||
        (currentSet.player2Games >= 6 &&
            currentSet.player2Games - currentSet.player1Games >= 2)) {
      // Check if the set win determines match winner
      bool matchEnded = false;
      int matchWinner = 0;

      final player1SetsWon =
          newSets.where((s) => s.player1Games > s.player2Games).length;
      final player2SetsWon =
          newSets.where((s) => s.player2Games > s.player1Games).length;

      if (player1SetsWon >= match.setsToWin) {
        matchEnded = true;
        matchWinner = 1;
      } else if (player2SetsWon >= match.setsToWin) {
        matchEnded = true;
        matchWinner = 2;
      }

      if ((newSets[currentSetIndex].player1Games + newSets[currentSetIndex].player2Games) % 2 != 0) {
        leftPlayer = leftPlayer == 1 ? 2 : 1;
      }

      // Start a new set if match hasn't ended
      if (!matchEnded) {
        newSets.add(SetScore.newSet());
      }

      final updatedMatch = match.copyWith(
        sets: newSets,
        currentGameScore1: newScore1,
        currentGameScore2: newScore2,
        servingPlayer: newServingPlayer,
        isCompleted: matchEnded,
        winner: matchWinner,
        pointHistory: updatedPointHistory,
        leftPlayer: leftPlayer,
      );

      final updatedMatches = [...state.matches];
      updatedMatches[matchIndex] = updatedMatch;

      emit(state.copyWith(matches: updatedMatches));
      return;
    }

    // Just update the game score
    final updatedMatch = match.copyWith(
      sets: newSets,
      currentGameScore1: newScore1,
      currentGameScore2: newScore2,
      servingPlayer: newServingPlayer,
      pointHistory: updatedPointHistory,
    );

    final updatedMatches = [...state.matches];
    updatedMatches[matchIndex] = updatedMatch;

    emit(state.copyWith(matches: updatedMatches));
  }

  // New method for adding an ace
  void _onAddAce(AddAce event, Emitter<MatchState> emit) {
    // An ace counts as a point, so we'll reuse the AddPoint logic
    // but we could also increment an ace counter if we wanted to track stats

    final matchIndex = state.matches.indexWhere((m) => m.id == event.matchId);
    if (matchIndex == -1) return;

    final match = state.matches[matchIndex];
    if (match.isCompleted) return;

    // Here we could add ace statistics tracking if needed:
    // final updatedMatch = match.copyWith(
    //   acesByPlayer1: event.player == 1 ? match.acesByPlayer1 + 1 : match.acesByPlayer1,
    //   acesByPlayer2: event.player == 2 ? match.acesByPlayer2 + 1 : match.acesByPlayer2,
    // );

    // Call the regular point addition logic
    add(AddPoint(event.matchId, event.player));
  }

  // New method for adding a fault
  void _onAddFault(AddFault event, Emitter<MatchState> emit) {
    final matchIndex = state.matches.indexWhere((m) => m.id == event.matchId);
    if (matchIndex == -1) return;

    final match = state.matches[matchIndex];
    if (match.isCompleted) return;

    // If it's a double fault, the opponent gets the point
    if (event.isDoubleFault) {
      // Determine which player gets the point (opponent of the one who faulted)
      final scoringPlayer = event.player == 1 ? 2 : 1;

      // Here we could add double fault statistics tracking if needed:
      // final updatedMatch = match.copyWith(
      //   doubleFaultsByPlayer1: event.player == 1 ? match.doubleFaultsByPlayer1 + 1 : match.doubleFaultsByPlayer1,
      //   doubleFaultsByPlayer2: event.player == 2 ? match.doubleFaultsByPlayer2 + 1 : match.doubleFaultsByPlayer2,
      // );

      // Award point to opponent
      add(AddPoint(event.matchId, scoringPlayer));
    }
    // For a single fault, no point is awarded yet
    // but we could track it for statistics if needed
  }

  // Fixed the UndoLastPoint method
  void _onUndoLastPoint(UndoLastPoint event, Emitter<MatchState> emit) {
    final matchIndex = state.matches.indexWhere((m) => m.id == event.matchId);
    if (matchIndex == -1) return;

    final match = state.matches[matchIndex];
    if (match.pointHistory.isEmpty) return;

    // Get the previous state by removing the last entry
    final List<PointHistoryEntry> updatedPointHistory = List.from(match.pointHistory);
    final lastPoint = updatedPointHistory.removeLast(); // Remove the last entry

    if (updatedPointHistory.isEmpty) {
      // If no history left, reset to initial state
      final List<SetScore> initialSets = [SetScore.newSet()];

      final updatedMatch = match.copyWith(
        currentGameScore1: 0,
        currentGameScore2: 0,
        sets: initialSets,
        servingPlayer: match.servingPlayer, // Keep the current server
        pointHistory: updatedPointHistory,
        isCompleted: false,
        winner: 0,
      );

      final updatedMatches = [...state.matches];
      updatedMatches[matchIndex] = updatedMatch;

      emit(state.copyWith(matches: updatedMatches));
      return;
    }

    // Get previous state (the state before the point was played)
    final previousState = updatedPointHistory.last;

    // Create a new match with the previous state values
    final updatedMatch = match.copyWith(
      currentGameScore1: lastPoint.currentGameScore1,
      currentGameScore2: lastPoint.currentGameScore2,
      sets: List.from(previousState.setScores),
      servingPlayer: previousState.servingPlayer,
      pointHistory: updatedPointHistory,
      isCompleted: false, // Ensure match is not marked as completed if undoing the final point
      winner: 0,          // Reset winner if undoing the final point
    );

    final updatedMatches = [...state.matches];
    updatedMatches[matchIndex] = updatedMatch;

    emit(state.copyWith(matches: updatedMatches));
  }

  void _onToggleServe(ToggleServe event, Emitter<MatchState> emit) {
    final matchIndex = state.matches.indexWhere((m) => m.id == event.matchId);
    if (matchIndex == -1) return;

    final match = state.matches[matchIndex];
    final newServingPlayer = match.servingPlayer == 1 ? 2 : 1;

    final updatedMatch = match.copyWith(servingPlayer: newServingPlayer);

    final updatedMatches = [...state.matches];
    updatedMatches[matchIndex] = updatedMatch;

    emit(state.copyWith(matches: updatedMatches));
  }

  void _onEndMatch(EndMatch event, Emitter<MatchState> emit) {
    final matchIndex = state.matches.indexWhere((m) => m.id == event.matchId);
    if (matchIndex == -1) return;

    final match = state.matches[matchIndex];

    // Determine winner based on sets won
    final player1SetsWon =
        match.sets.where((s) => s.player1Games > s.player2Games).length;
    final player2SetsWon =
        match.sets.where((s) => s.player2Games > s.player1Games).length;

    int winner = 0;
    if (player1SetsWon > player2SetsWon) {
      winner = 1;
    } else if (player2SetsWon > player1SetsWon) {
      winner = 2;
    } else {
      // If sets are equal, determine by current set score
      final currentSet = match.sets.last;
      if (currentSet.player1Games > currentSet.player2Games) {
        winner = 1;
      } else if (currentSet.player2Games > currentSet.player1Games) {
        winner = 2;
      } else {
        // If current set is tied, check current game score
        if (match.currentGameScore1 > match.currentGameScore2) {
          winner = 1;
        } else if (match.currentGameScore2 > match.currentGameScore1) {
          winner = 2;
        } else {
          // If everything is tied, default to player 1
          winner = 1;
        }
      }
    }

    final updatedMatch = match.copyWith(isCompleted: true, winner: winner);

    final updatedMatches = [...state.matches];
    updatedMatches[matchIndex] = updatedMatch;

    emit(state.copyWith(matches: updatedMatches));
  }
}