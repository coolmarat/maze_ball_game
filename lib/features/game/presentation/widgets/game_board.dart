import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../../domain/entities/maze.dart';
import '../game/maze_game.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  MazeGame? _game;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listenWhen: (previous, current) => 
        previous.playerPosition != current.playerPosition,
      listener: (context, state) {
        if (state.playerPosition != null && _game != null) {
          _game!.updatePlayerPosition(state.playerPosition!);
        }
      },
      buildWhen: (previous, current) =>
        previous.maze != current.maze ||
        previous.settings != current.settings,
      builder: (context, state) {
        if (state.maze == null) {
          return const Center(child: Text('Start a new game'));
        }

        _game = MazeGame(
          maze: state.maze!,
          playerPosition: state.playerPosition!,
          settings: state.settings!,
        );

        return GameWidget(game: _game!);
      },
    );
  }
}
