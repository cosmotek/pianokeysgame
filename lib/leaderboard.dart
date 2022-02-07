import 'package:flutter/material.dart';
import 'package:pianokeysgame/score_database.dart';

import 'main.dart';

Widget LeaderboardPage() {
  return Builder(
    builder: (context) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.of(context).pushNamed("/home");
      });

      print(globals.get<ScoreDatabase>().getMostRecentScore());

      return Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(20),
              child: Text(
                "Scoreboard",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...globals.get<ScoreDatabase>().getTop10Scores().
              asMap().map((index, score) =>
                MapEntry(
                  index, 
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "${index+1}. ${score.playerInitials} ${score.score}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: score.score == globals.get<ScoreDatabase>().getMostRecentScore() ? Colors.red : Colors.black,
                      ),
                    )
                  )
                )
              ).values.toList(),
          ],
        ),
      );
    },
  );
}
