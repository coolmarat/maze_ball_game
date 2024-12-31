import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  List<Object> get props => [x, y];
}

class Cell extends Equatable {
  final bool topWall;
  final bool rightWall;
  final bool bottomWall;
  final bool leftWall;

  const Cell({
    required this.topWall,
    required this.rightWall,
    required this.bottomWall,
    required this.leftWall,
  });

  @override
  List<Object> get props => [topWall, rightWall, bottomWall, leftWall];
}

class Maze extends Equatable {
  final List<List<Cell>> grid;
  final Position start;
  final Position end;
  final int width;
  final int height;

  const Maze({
    required this.grid,
    required this.start,
    required this.end,
    required this.width,
    required this.height,
  });

  @override
  List<Object> get props => [grid, start, end, width, height];
}
