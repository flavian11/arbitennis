import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final int? ranking;
  final String? country;
  final int aces;
  final int doubleFaults;
  final int winnersCount;
  final int unforcedErrors;

  const Player({
    required this.id,
    required this.name,
    this.ranking,
    this.country,
    this.aces = 0,
    this.doubleFaults = 0,
    this.winnersCount = 0,
    this.unforcedErrors = 0,
  });

  factory Player.create({
    required String name,
    int? ranking,
    String? country,
  }) {
    return Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      ranking: ranking,
      country: country,
    );
  }

  Player copyWith({
    String? id,
    String? name,
    int? ranking,
    String? country,
    int? aces,
    int? doubleFaults,
    int? winnersCount,
    int? unforcedErrors,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      ranking: ranking ?? this.ranking,
      country: country ?? this.country,
      aces: aces ?? this.aces,
      doubleFaults: doubleFaults ?? this.doubleFaults,
      winnersCount: winnersCount ?? this.winnersCount,
      unforcedErrors: unforcedErrors ?? this.unforcedErrors,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    ranking,
    country,
    aces,
    doubleFaults,
    winnersCount,
    unforcedErrors,
  ];
}