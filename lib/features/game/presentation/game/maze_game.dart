import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import '../../domain/entities/maze.dart';
import '../../domain/entities/game_settings.dart';

class MazeGame extends FlameGame {
  final Maze maze;
  Position _playerPosition;
  final GameSettings settings;
  late final World _world;
  late final CameraComponent _camera;
  late final CircleComponent _player;
  VisibilityMask? _visibilityMask;

  MazeGame({
    required this.maze,
    required Position playerPosition,
    required this.settings,
  }) : _playerPosition = playerPosition;

  void updatePlayerPosition(Position newPosition) {
    _playerPosition = newPosition;
    _player.position = Vector2(
      newPosition.x.toDouble() + 0.6 - 0.4,
      newPosition.y.toDouble() + 0.6 - 0.4,
    );
    if (_visibilityMask != null) {
      _visibilityMask!.updatePosition(Vector2(
        newPosition.x.toDouble() + 0.5,
        newPosition.y.toDouble() + 0.5,
      ));
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
      size: Vector2(maze.width.toDouble(), maze.height.toDouble()),
      paint: Paint()..color = const Color(0xFFFFFFFF),
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
      radius: 0.4,
      paint: Paint()..color = const Color(0xFF0000FF),
      position: Vector2(
        _playerPosition.x.toDouble() + 0.5 - 0.4,
        _playerPosition.y.toDouble() + 0.5 - 0.4,
      ),
    );
    await _world.add(_player);

    // Add visibility mask if needed
    if (settings.limitedVisibility) {
      _visibilityMask = VisibilityMask(
        position: Vector2(
          _playerPosition.x.toDouble() + 0.5,
          _playerPosition.y.toDouble() + 0.5,
        ),
        size: Vector2(maze.width.toDouble(), maze.height.toDouble()),
        radius: settings.visibilityRadius.toDouble(),
      );
      await _world.add(_visibilityMask!);
    }

    // Add finish point (always visible)
    final finish = CircleComponent(
      radius: 0.4,
      paint: Paint()..color = const Color(0xFF00FF00),
      position: Vector2(
        maze.end.x.toDouble() + 0.5 - 0.4,
        maze.end.y.toDouble() + 0.5 - 0.4,
      ),
    );
    await _world.add(finish);

    // Set up camera
    _camera.viewfinder.zoom = 25.0;
    _camera.viewfinder.position = Vector2(
      maze.width.toDouble() / 2,
      maze.height.toDouble() / 2,
    );
  }

  Future<void> _addWall(double x, double y, bool horizontal) async {
    final wall = RectangleComponent(
      position: Vector2(x, y),
      size: Vector2(
        horizontal ? 1.0 : 0.15,
        horizontal ? 0.15 : 1.0,
      ),
      paint: Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.fill,
    );
    await _world.add(wall);
  }
}

class VisibilityMask extends PositionComponent {
  final Vector2 _holePosition;
  final double radius;
  final Paint _paint;

  VisibilityMask({
    required Vector2 position,
    required Vector2 size,
    required this.radius,
  }) : _holePosition = position.clone(),
       _paint = Paint()..color = const Color(0xFFFFFFFF),
       super(size: size);

  void updatePosition(Vector2 newPosition) {
    _holePosition.setFrom(newPosition);
  }

  @override
  void render(Canvas canvas) {
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..blendMode = BlendMode.dstOut,
    );
    
    // Draw white background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      _paint,
    );

    // Create circular hole
    canvas.drawCircle(
      Offset(_holePosition.x, _holePosition.y),
      radius,
      Paint()
        ..color = const Color(0xFF000000)
        ..blendMode = BlendMode.clear,
    );

    canvas.restore();
  }
}
