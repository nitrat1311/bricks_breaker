import 'package:ball_master/ball_master.dart';
import 'package:ball_master/components/ball.dart';
import 'package:ball_master/utils/constants.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Brick extends SpriteComponent
    with CollisionCallbacks, HasGameRef<BricksBreaker> {
  Brick({
    required this.brickValue,
    required double size,
  }) : super(
          size: Vector2.all(size),
        );

  int brickValue;
  bool hasCollided = false;
  late final TextComponent brickText;
  late final RectangleHitbox rectangleBrickHitBox;
  late final SpriteComponent rectangleBrick;

  @override
  Future<void> onLoad() async {
          await gameRef.images.loadAll([
        'brick.webp',
      ]);

          sprite = await gameRef.loadSprite(
      'brick.webp',
    );
    if (brickValue <= 0) {
      removeFromParent();
      return;
    }

    brickText = createBrickTextComponent();
    rectangleBrick = createBrickRectangleComponent();
    rectangleBrickHitBox = createBrickRectangleHitbox();

    addAll([
      rectangleBrick,
      rectangleBrickHitBox,
      brickText,
    ]);
  }

  @override
  void update(double dt) {
    if (hasCollided) {
      brickText.text = '$brickValue';
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Ball && !hasCollided) {
      hasCollided = true;
      handleCollision();
    }
    super.onCollision(intersectionPoints, other);
  }

  TextComponent createBrickTextComponent() {
    return TextComponent(
      text: '$brickValue',
      textRenderer: TextPaint(
        style:  TextStyle(
          color: const Color(brickFontColor),
          fontSize: brickFontSize,
          background: Paint()..color=const Color(textBackColor)
        ),
      ),
    )..center = size / 2;
  }

  RectangleHitbox createBrickRectangleHitbox() {
    return RectangleHitbox(
      size: size,
    );
  }

  SpriteComponent createBrickRectangleComponent() {
    return SpriteComponent(
      sprite: sprite,
      size: size,
      paint: Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(brickColor),
    );
  }

  void handleCollision() {
    if (--brickValue == 0) {
      removeFromParent();
      return;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (hasCollided) {
      hasCollided = false;
    }
    super.onCollisionEnd(other);
  }
}
