import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import '../../domain/entities/maze.dart';
import '../../domain/entities/game_settings.dart';

class MazeGame extends FlameGame {
  final Maze maze;
  Position _playerPosition;
  final GameSettings settings;
  final double availableWidth;
  final double availableHeight;
  late final World _world;
  late final CameraComponent _camera;
  late final CircleComponent _player;
  VisibilityMask? _visibilityMask;
  late final double _cellSize;

  MazeGame({
    required this.maze,
    required Position playerPosition,
    required this.settings,
    required this.availableWidth,
    required this.availableHeight,
  }) : _playerPosition = playerPosition {
    final horizontalCellSize = availableWidth / maze.width;
    final verticalCellSize = availableHeight / maze.height;
    _cellSize = horizontalCellSize < verticalCellSize ? horizontalCellSize : verticalCellSize;
  }

  Vector2 _getCellCenter(double x, double y) {
    return Vector2(
      (x + 0.5) * _cellSize,
      (y + 0.5) * _cellSize,
    );
  }

  void updatePlayerPosition(Position newPosition) {
    _playerPosition = newPosition;
    _player.position = _getCellCenter(newPosition.x.toDouble(), newPosition.y.toDouble());
    if (_visibilityMask != null) {
      _visibilityMask!.updatePosition(_getCellCenter(newPosition.x.toDouble(), newPosition.y.toDouble()));
    }
  }

  @override
  Future<void> onLoad() async {
    _world = World();
    _camera = CameraComponent(world: _world);
    
    await addAll([_world, _camera]);

    // Add white background
    final background = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(maze.width * _cellSize, maze.height * _cellSize),
      paint: Paint()..color = const Color(0xFFFFFFFF),
      priority: 0,
    );
    await _world.add(background);

    // Add maze walls
    for (int y = 0; y < maze.height; y++) {
      for (int x = 0; x < maze.width; x++) {
        final cell = maze.grid[y][x];
        if (cell.topWall) {
          await _addWall(x.toDouble(), y.toDouble(), true);
        }
        if (cell.rightWall) {
          await _addWall(x + 1.0, y.toDouble(), false);
        }
        if (cell.bottomWall) {
          await _addWall(x.toDouble(), y + 1.0, true);
        }
        if (cell.leftWall) {
          await _addWall(x.toDouble(), y.toDouble(), false);
        }
      }
    }

    // Add player
    _player = CircleComponent(
      radius: _cellSize * 0.4,
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF0000FF),
      position: _getCellCenter(_playerPosition.x.toDouble(), _playerPosition.y.toDouble()),
      priority: 3,
    );
    await _world.add(_player);

    if (settings.limitedVisibility) {
      _visibilityMask = VisibilityMask(
        position: _getCellCenter(_playerPosition.x.toDouble(), _playerPosition.y.toDouble()),
        size: Vector2(maze.width * _cellSize, maze.height * _cellSize),
        radius: settings.visibilityRadius * _cellSize,
        finishPosition: _getCellCenter(maze.end.x.toDouble(), maze.end.y.toDouble()),
        finishRadius: _cellSize * 0.4,
      );
      await _world.add(_visibilityMask!);
    }

    // Set up camera
    _camera.viewfinder.zoom = 1.0;
    _camera.viewfinder.position = Vector2(
      maze.width * _cellSize / 2,
      maze.height * _cellSize / 2,
    );
  }

  Future<void> _addWall(double x, double y, bool horizontal) async {
    final wall = RectangleComponent(
      position: Vector2(
        x * _cellSize,
        y * _cellSize,
      ),
      size: Vector2(
        horizontal ? _cellSize : _cellSize * 0.1,
        horizontal ? _cellSize * 0.1 : _cellSize,
      ),
      paint: Paint()..color = const Color(0xFF000000),
      priority: 1,
    );
    await _world.add(wall);
  }
}

class VisibilityMask extends PositionComponent with HasGameRef {
  final Vector2 _holePosition;
  final double radius;
  final Vector2 _finishPosition;
  final double _finishRadius;
  late final Paint _maskPaint;
  late final Paint _finishPaint;

  VisibilityMask({
    required Vector2 position,
    required Vector2 size,
    required this.radius,
    required Vector2 finishPosition,
    required double finishRadius,
  }) : _holePosition = position.clone(),
       _finishPosition = finishPosition.clone(),
       _finishRadius = finishRadius,
       super(size: size) {
    _maskPaint = Paint()
      ..color = const Color(0xFF000000)
      ..blendMode = BlendMode.dstOut;
    _finishPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..blendMode = BlendMode.srcOver;
    priority = 100;
  }

  void updatePosition(Vector2 newPosition) {
    _holePosition.setFrom(newPosition);
  }

  @override
  void render(Canvas canvas) {
    // Сначала рисуем маску видимости
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.x, size.y), Paint());
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF000000),
    );

    canvas.drawCircle(
      Offset(_holePosition.x, _holePosition.y),
      radius,
      _maskPaint,
    );

    canvas.restore();

    // Затем рисуем финишную точку поверх всего
    canvas.drawCircle(
      Offset(_finishPosition.x, _finishPosition.y),
      _finishRadius,
      _finishPaint,
    );
  }
}
