import 'package:ball_master/game_page.dart';
import 'package:ball_master/utils/constants.dart';
import 'package:flutter/material.dart';

class BricksBreakerGame extends StatelessWidget {
  const BricksBreakerGame({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: gameTitle,
      theme: ThemeData.dark(),
      home: const GamePage(title: gameTitle),
    );
  }
}
