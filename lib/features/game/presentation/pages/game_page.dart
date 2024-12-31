import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../widgets/game_board.dart';
import '../widgets/game_controls.dart';
import '../../domain/entities/game_settings.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<GameBloc, GameState>(
          buildWhen: (previous, current) => previous.elapsedTime != current.elapsedTime,
          builder: (context, state) {
            if (state.elapsedTime == null) return const Text('Лабиринт');
            final minutes = state.elapsedTime!.inMinutes;
            final seconds = state.elapsedTime!.inSeconds % 60;
            final milliseconds = state.elapsedTime!.inMilliseconds % 1000;
            return Text(
              'Время: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 20),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state.maze == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () => _showSettingsDialog(context),
                    child: const Text('Начать новую игру'),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () => _showSettingsDialog(context),
                    child: const Icon(Icons.settings),
                  ),
                ],
              ),
            );
          }
          
          return BlocListener<GameBloc, GameState>(
            listenWhen: (previous, current) => 
              !previous.isGameComplete && current.isGameComplete,
            listener: (context, state) {
              if (state.isGameComplete) {
                _showCompletionDialog(context, state.elapsedTime!);
              }
            },
            child: Column(
              children: [
                const Expanded(
                  child: GameBoard(),
                ),
                const GameControls(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GameBloc>(),
        child: const GameSettingsDialog(),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, Duration time) {
    final minutes = time.inMinutes;
    final seconds = time.inSeconds % 60;
    final milliseconds = time.inMilliseconds % 1000;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GameBloc>(),
        child: AlertDialog(
          title: const Text('Поздравляем!'),
          content: Text(
            'Вы прошли лабиринт за ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}!',
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showSettingsDialog(context);
              },
              child: const Text('Начать новую игру'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameSettingsDialog extends StatefulWidget {
  const GameSettingsDialog({super.key});

  @override
  State<GameSettingsDialog> createState() => _GameSettingsDialogState();
}

class _GameSettingsDialogState extends State<GameSettingsDialog> {
  double _difficulty = 1;
  bool _limitedVisibility = false;
  double _visibilityRadius = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Настройки игры'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Сложность'),
          Slider(
            value: _difficulty,
            min: 1,
            max: 10,
            divisions: 9,
            label: _difficulty.round().toString(),
            onChanged: (value) => setState(() => _difficulty = value),
          ),
          CheckboxListTile(
            title: const Text('Ограниченная видимость'),
            value: _limitedVisibility,
            onChanged: (value) => setState(() => _limitedVisibility = value!),
          ),
          if (_limitedVisibility) ...[
            const Text('Радиус видимости'),
            Slider(
              value: _visibilityRadius,
              min: 1,
              max: 5,
              divisions: 4,
              label: _visibilityRadius.round().toString(),
              onChanged: (value) => setState(() => _visibilityRadius = value),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            context.read<GameBloc>().add(
              StartGame(
                GameSettings(
                  difficulty: _difficulty.round(),
                  limitedVisibility: _limitedVisibility,
                  visibilityRadius: _visibilityRadius,
                ),
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Начать игру'),
        ),
      ],
    );
  }
}
