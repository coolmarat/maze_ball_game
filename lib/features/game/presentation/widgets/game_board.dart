import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/maze.dart';
import '../game/maze_game.dart';
import '../../domain/entities/game_settings.dart';

class GameBoard extends StatefulWidget {
  final double availableWidth;
  final double availableHeight;
  final Maze maze;
  final Position playerPosition;
  final GameSettings settings;

  const GameBoard({
    super.key,
    required this.availableWidth,
    required this.availableHeight,
    required this.maze,
    required this.playerPosition,
    required this.settings,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late MazeGame _game;
  Key _gameKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maze != widget.maze || oldWidget.settings != widget.settings) {
      setState(() {
        _initializeGame();
        _gameKey = UniqueKey(); // Форсируем пересоздание GameWidget
      });
    } else if (oldWidget.playerPosition != widget.playerPosition) {
      _game.updatePlayerPosition(widget.playerPosition);
    }
  }

  void _initializeGame() {
    _game = MazeGame(
      maze: widget.maze,
      playerPosition: widget.playerPosition,
      settings: widget.settings,
      availableWidth: widget.availableWidth,
      availableHeight: widget.availableHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(
      key: _gameKey,
      gameFactory: () => _game,
    );
  }
}
