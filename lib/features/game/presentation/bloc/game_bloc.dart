import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/maze.dart';
import '../../domain/entities/game_settings.dart';
import '../../domain/repositories/game_repository.dart';

// Events
abstract class GameEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StartGame extends GameEvent {
  final GameSettings settings;
  StartGame(this.settings);

  @override
  List<Object> get props => [settings];
}

class MovePlayer extends GameEvent {
  final Direction direction;
  MovePlayer(this.direction);

  @override
  List<Object> get props => [direction];
}

class UpdateTimer extends GameEvent {
  final Duration duration;
  
  UpdateTimer(this.duration);
}

enum Direction { up, right, down, left }

// State
class GameState extends Equatable {
  final Maze? maze;
  final Position? playerPosition;
  final GameSettings? settings;
  final bool isGameComplete;
  final Duration? elapsedTime;
  final bool isPlaying;

  const GameState({
    this.maze,
    this.playerPosition,
    this.settings,
    this.isGameComplete = false,
    this.elapsedTime,
    this.isPlaying = false,
  });

  GameState copyWith({
    Maze? maze,
    Position? playerPosition,
    GameSettings? settings,
    bool? isGameComplete,
    Duration? elapsedTime,
    bool? isPlaying,
  }) {
    return GameState(
      maze: maze ?? this.maze,
      playerPosition: playerPosition ?? this.playerPosition,
      settings: settings ?? this.settings,
      isGameComplete: isGameComplete ?? this.isGameComplete,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [maze, playerPosition, settings, isGameComplete, elapsedTime, isPlaying];
}

// Bloc
class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository gameRepository;
  Timer? _timer;

  GameBloc(this.gameRepository) : super(const GameState()) {
    on<StartGame>(_onStartGame);
    on<MovePlayer>(_onMovePlayer);
    on<UpdateTimer>(_onUpdateTimer);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    _timer?.cancel();
    final maze = gameRepository.generateMaze(event.settings);
    emit(GameState(
      maze: maze,
      playerPosition: maze.start,
      settings: event.settings,
      isPlaying: false,
      isGameComplete: false,
      elapsedTime: Duration.zero,
    ));
  }

  void _onMovePlayer(MovePlayer event, Emitter<GameState> emit) {
    if (state.maze == null || state.playerPosition == null) return;

    // Start timer on first move if not already playing
    if (!state.isPlaying) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        add(UpdateTimer(Duration(milliseconds: timer.tick * 100)));
      });
      emit(state.copyWith(isPlaying: true));
    }

    final nextPosition = gameRepository.getNextJunctionOrDeadEnd(
      state.playerPosition!,
      event.direction,
      state.maze!,
    );
    
    final isComplete = gameRepository.isGameComplete(nextPosition, state.maze!);
    
    if (isComplete) {
      _timer?.cancel();
    }
    
    emit(state.copyWith(
      playerPosition: nextPosition,
      isGameComplete: isComplete,
      isPlaying: !isComplete,
    ));
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<GameState> emit) {
    emit(state.copyWith(elapsedTime: event.duration));
  }
}
