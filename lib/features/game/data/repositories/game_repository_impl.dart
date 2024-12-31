import '../../domain/entities/maze.dart';
import '../../domain/entities/game_settings.dart';
import '../../domain/repositories/game_repository.dart';
import 'dart:math';

import '../../presentation/bloc/game_bloc.dart';

class GameRepositoryImpl implements GameRepository {
  @override
  Maze generateMaze(GameSettings settings) {
    final width = 10 + settings.difficulty * 2;
    final height = 10 + settings.difficulty * 2;
    final random = Random();

    // Initialize grid with all walls
    final grid = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) => const Cell(
          topWall: true,
          rightWall: true,
          bottomWall: true,
          leftWall: true,
        ),
      ),
    );

    // Generate maze using recursive backtracking
    final visited = List.generate(height, (y) => List.filled(width, false));
    final stack = <Position>[];
    
    final start = Position(0, 0);
    stack.add(start);
    visited[start.y][start.x] = true;

    while (stack.isNotEmpty) {
      final current = stack.last;
      final neighbors = _getUnvisitedNeighbors(current, width, height, visited);

      if (neighbors.isEmpty) {
        stack.removeLast();
        continue;
      }

      final next = neighbors[random.nextInt(neighbors.length)];
      _removeWallBetween(grid, current, next);
      visited[next.y][next.x] = true;
      stack.add(next);
    }

    // Ensure at least one path exists
    final end = Position(width - 1, height - 1);

    return Maze(
      grid: grid,
      start: start,
      end: end,
      width: width,
      height: height,
    );
  }

  List<Position> _getUnvisitedNeighbors(
    Position pos,
    int width,
    int height,
    List<List<bool>> visited,
  ) {
    final neighbors = <Position>[];
    final directions = [
      Position(0, -1), // up
      Position(1, 0),  // right
      Position(0, 1),  // down
      Position(-1, 0), // left
    ];

    for (final dir in directions) {
      final newX = pos.x + dir.x;
      final newY = pos.y + dir.y;

      if (newX >= 0 && newX < width && newY >= 0 && newY < height && !visited[newY][newX]) {
        neighbors.add(Position(newX, newY));
      }
    }

    return neighbors;
  }

  void _removeWallBetween(List<List<Cell>> grid, Position current, Position next) {
    final dx = next.x - current.x;
    final dy = next.y - current.y;

    if (dx == 1) {
      // Remove right wall of current and left wall of next
      grid[current.y][current.x] = Cell(
        topWall: grid[current.y][current.x].topWall,
        rightWall: false,
        bottomWall: grid[current.y][current.x].bottomWall,
        leftWall: grid[current.y][current.x].leftWall,
      );
      grid[next.y][next.x] = Cell(
        topWall: grid[next.y][next.x].topWall,
        rightWall: grid[next.y][next.x].rightWall,
        bottomWall: grid[next.y][next.x].bottomWall,
        leftWall: false,
      );
    } else if (dx == -1) {
      // Remove left wall of current and right wall of next
      grid[current.y][current.x] = Cell(
        topWall: grid[current.y][current.x].topWall,
        rightWall: grid[current.y][current.x].rightWall,
        bottomWall: grid[current.y][current.x].bottomWall,
        leftWall: false,
      );
      grid[next.y][next.x] = Cell(
        topWall: grid[next.y][next.x].topWall,
        rightWall: false,
        bottomWall: grid[next.y][next.x].bottomWall,
        leftWall: grid[next.y][next.x].leftWall,
      );
    } else if (dy == 1) {
      // Remove bottom wall of current and top wall of next
      grid[current.y][current.x] = Cell(
        topWall: grid[current.y][current.x].topWall,
        rightWall: grid[current.y][current.x].rightWall,
        bottomWall: false,
        leftWall: grid[current.y][current.x].leftWall,
      );
      grid[next.y][next.x] = Cell(
        topWall: false,
        rightWall: grid[next.y][next.x].rightWall,
        bottomWall: grid[next.y][next.x].bottomWall,
        leftWall: grid[next.y][next.x].leftWall,
      );
    } else if (dy == -1) {
      // Remove top wall of current and bottom wall of next
      grid[current.y][current.x] = Cell(
        topWall: false,
        rightWall: grid[current.y][current.x].rightWall,
        bottomWall: grid[current.y][current.x].bottomWall,
        leftWall: grid[current.y][current.x].leftWall,
      );
      grid[next.y][next.x] = Cell(
        topWall: grid[next.y][next.x].topWall,
        rightWall: grid[next.y][next.x].rightWall,
        bottomWall: false,
        leftWall: grid[next.y][next.x].leftWall,
      );
    }
  }

  @override
  bool isValidMove(Position currentPosition, Position nextPosition, Maze maze) {
    if (nextPosition.x < 0 || nextPosition.x >= maze.width ||
        nextPosition.y < 0 || nextPosition.y >= maze.height) {
      return false;
    }

    final dx = nextPosition.x - currentPosition.x;
    final dy = nextPosition.y - currentPosition.y;

    if (dx == 1) {
      return !maze.grid[currentPosition.y][currentPosition.x].rightWall;
    } else if (dx == -1) {
      return !maze.grid[currentPosition.y][currentPosition.x].leftWall;
    } else if (dy == 1) {
      return !maze.grid[currentPosition.y][currentPosition.x].bottomWall;
    } else if (dy == -1) {
      return !maze.grid[currentPosition.y][currentPosition.x].topWall;
    }

    return false;
  }

  @override
  bool isGameComplete(Position currentPosition, Maze maze) {
    return currentPosition.x == maze.end.x && currentPosition.y == maze.end.y;
  }

  @override
  Position getNextJunctionOrDeadEnd(Position start, Direction direction, Maze maze) {
    Position current = start;
    Position next = _getNextPosition(current, direction);
    
    // First move must be valid
    if (!isValidMove(current, next, maze)) {
      return current;
    }
    
    current = next;
    
    while (true) {
      // Count possible directions from current position
      int possibleMoves = 0;
      for (Direction dir in Direction.values) {
        next = _getNextPosition(current, dir);
        if (isValidMove(current, next, maze)) {
          possibleMoves++;
        }
      }
      
      // Stop if we're at a junction (more than 2 possible moves)
      // or at a dead end (only 1 possible move - the way back)
      if (possibleMoves != 2) {
        return current;
      }
      
      // Continue in the same direction
      next = _getNextPosition(current, direction);
      if (!isValidMove(current, next, maze)) {
        return current;
      }
      current = next;
    }
  }
  
  Position _getNextPosition(Position current, Direction direction) {
    switch (direction) {
      case Direction.up:
        return Position(current.x, current.y - 1);
      case Direction.right:
        return Position(current.x + 1, current.y);
      case Direction.down:
        return Position(current.x, current.y + 1);
      case Direction.left:
        return Position(current.x - 1, current.y);
    }
  }
}
