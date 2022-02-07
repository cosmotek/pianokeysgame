
import 'dart:convert';

import 'dart:io';

class Score {
  final String playerInitials;
  final int score;
  final DateTime recordedAt;

  Score({ required this.playerInitials, required this.score, required this.recordedAt });

  Score.fromJson(Map<String, dynamic> json)
      : playerInitials = json['playerInitials'],
        score = json['score'],
        recordedAt = DateTime.fromMicrosecondsSinceEpoch(json['recordedAt']);

  Map<String, dynamic> toJson() => {
    'playerInitials': playerInitials,
    'score': score,
    'recordedAt': recordedAt.millisecondsSinceEpoch,
  };
}

class ScoreDatabase {
  ScoreDatabase() {
    _loadData();
  }

  List<Score> _scores = [];

  List<Score> getTop10Scores() {
    return _scores;
  }

  int getMostRecentScore() {
    if (_scores.length < 0) {
      return 0;
    }

    List<Score> _t = [..._scores];
    _t.sort((a, b) {
      if (a.recordedAt.millisecondsSinceEpoch < b.recordedAt.millisecondsSinceEpoch) {
        return 1;
      }

      if (b.recordedAt.millisecondsSinceEpoch < a.recordedAt.millisecondsSinceEpoch) {
        return -1;
      }

      return 0;
    });

    return _t[0].score;
  }

  void addScore(Score score) {
    for (int i = 0; i < _scores.length; i++) {
      Score oldScore = _scores[i];
      if (oldScore.score == score.score) {
        // skip add because older score exists
        return;
      }
    }

    _scores.add(score);
    _scores.sort((a, b) {
      if (a.score < b.score) {
        return 1;
      }

      if (b.score < a.score) {
        return -1;
      }

      return 0;
    });

    if (_scores.length > 10) {
      _scores = _scores.sublist(0, 11);
    }

    _persistData();
  }

  void _persistData() async {
    await File("pianokeysgame_scores.json").
      writeAsString(jsonEncode({
        "scores": _scores.map((item) => item.toJson()).toList(),
      }));
  }

  void _loadData() async {
    String fileContents = await File("pianokeysgame_scores.json").readAsString();
    Map<String, dynamic> data = jsonDecode(fileContents);

    _scores = (data["scores"] as List<dynamic>).map((item) =>
      Score.fromJson(item)).toList();

    _scores.sort((a, b) {
      if (a.score < b.score) {
        return 1;
      }

      if (b.score < a.score) {
        return -1;
      }

      return 0;
    });
  }
}
