import '../../presentation/bloc/game_bloc.dart';
import '../entities/maze.dart';
import '../entities/game_settings.dart';

abstract class GameRepository {
  Maze generateMaze(GameSettings settings);
  bool isValidMove(Position currentPosition, Position nextPosition, Maze maze);
  bool isGameComplete(Position currentPosition, Maze maze);
  
  /// Returns the final position when moving in the given direction until reaching
  /// either a junction (multiple possible directions) or a dead end (no possible directions)
  Position getNextJunctionOrDeadEnd(Position start, Direction direction, Maze maze);
}
