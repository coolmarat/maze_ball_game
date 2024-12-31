import 'package:equatable/equatable.dart';

class GameSettings extends Equatable {
  final int difficulty;
  final bool limitedVisibility;
  final double visibilityRadius;

  const GameSettings({
    required this.difficulty,
    required this.limitedVisibility,
    required this.visibilityRadius,
  });

  @override
  List<Object> get props => [difficulty, limitedVisibility, visibilityRadius];
}
