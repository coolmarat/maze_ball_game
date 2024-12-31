import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/game/presentation/bloc/game_bloc.dart';
import 'features/game/presentation/pages/game_page.dart';
import 'features/game/data/repositories/game_repository_impl.dart';
import 'features/game/domain/repositories/game_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maze Ball Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: RepositoryProvider<GameRepository>(
        create: (context) => GameRepositoryImpl(),
        child: BlocProvider(
          create: (context) => GameBloc(
            context.read<GameRepository>(),
          ),
          child: const GamePage(),
        ),
      ),
    );
  }
}
