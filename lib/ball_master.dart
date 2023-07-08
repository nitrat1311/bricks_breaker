import 'dart:math';

import 'package:ball_master/components/ball.dart';
import 'package:ball_master/components/board.dart';
import 'package:ball_master/components/brick.dart';
import 'package:ball_master/managers/game_manager.dart';
import 'package:ball_master/utils/constants.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class BricksBreaker extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  BricksBreaker({super.children});

  final GameManager gameManager = GameManager();
  final Ball ball = Ball();
  final Board board = Board();
  int numberOfBricksLayer = 1;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(gameManager);

    ball.priority = 1;
    addAll([
      board,
      ball,
    ]);

    loadInitialBrickLayer();
  }

  void resetGame() {
    pauseEngine();
    overlays.remove('gamePauseOverlay');
    overlays.remove('gameOverOverlay');

    children.whereType<Brick>().forEach((brick) {
      brick.removeFromParent();
    });

    gameManager.reset();

    ball.resetBall();
    board.resetBoard();
    resumeEngine();

    numberOfBricksLayer = 1;
    loadInitialBrickLayer();
  }

  void togglePauseState() {
    if (paused) {
      overlays.remove('gamePauseOverlay');
      resumeEngine();
    } else {
      overlays.add('gamePauseOverlay');
      pauseEngine();
    }
  }

  double get brickSize {
    const totalPadding = (numberOfBricksInRow + 1) * brickPadding;
    final screenMinSize = size.x < size.y ? size.x : size.y;
    return (screenMinSize - totalPadding) / numberOfBricksInRow;
  }

  int next(int min, int max) => min + _random.nextInt(max);

  List<Brick> generateBrickLayer() {
    return List<Brick>.generate(
      numberOfBricksInRow,
      (index) => Brick(
        brickValue: next(minValueOfBrick, maxValueOfBrick),
        size: brickSize,
      ),
    );
  }

  Future<void> loadInitialBrickLayer() async {
    for (var row = 0; row < numberOfBricksLayer; row++) {
      final bricksLayer = generateBrickLayer();
      for (var i = 0; i < numberOfBricksInRow; i++) {
        final xPosition = i == 0
            ? 8
            : bricksLayer[i - 1].position.x + bricksLayer[i - 1].size.x + 8;
        final yPosition = (row + 1) * (brickSize + 8);

        await add(
          bricksLayer[i]..position = Vector2(xPosition.toDouble(), yPosition),
        );
      }
    }
  }

  @override
  Future<void> update(double dt) async {
    if (ball.ballState == BallState.completed) {
      await updateBrickPositions();
    }

    super.update(dt);
  }

  Future<void> updateBrickPositions() async {
    final brickComponents = children.whereType<Brick>().toList();

    for (final brick in brickComponents) {
      final nextYPosition = brick.position.y + brickSize + 8;
      if (board.size.y - ball.size.y <= nextYPosition + brick.size.y) {
        pauseEngine();

        gameManager.state = GameState.gameOver;
        ball.ballState = BallState.ideal;

        overlays.add('gameOverOverlay');

        return;
      }
      brick.position.y = nextYPosition;
    }

    final bricksLayer = generateBrickLayer();
    for (var i = 0; i < 7; i++) {
      await add(
        bricksLayer[i]
          ..position = Vector2(
            i == 0
                ? 8
                : bricksLayer[i - 1].position.x + bricksLayer[i - 1].size.x + 8,
            brickSize + 8,
          ),
      );
    }
    numberOfBricksLayer++;
    ball.ballState = BallState.ideal;
    gameManager.increaseScore();
  }

  void increaseBallSpeed() {
    ball.increaseSpeed();
  }
}
