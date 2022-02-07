import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:pianokeysgame/pianokey.dart';
import 'package:pianokeysgame/score_database.dart';
import 'package:pianokeysgame/timer_progressbar.dart';
import 'leaderboard.dart';
import 'package:confetti/confetti.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

GetIt globals = GetIt.instance;

void main() {
  globals.registerSingleton<ScoreDatabase>(ScoreDatabase());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/leaderboard": (context) => LeaderboardPage(),
        "/home": (context) => const MyHomePage(title: 'Flutter Demo Home Page')
      },
      initialRoute: "/home",
      scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
    );
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const keys = ["1", "2", "3", "4"];
const songDuration = Duration(seconds: 10);

class _MyHomePageState extends State<MyHomePage> {
  ItemScrollController scrollController = ItemScrollController();
  StreamController<bool> startController = StreamController<bool>();
  ConfettiController confettiController = ConfettiController();

  int selectedIndex = 0;
  bool songComplete = false;

  double keyHeight = 175;
  double keyWidth = 100;

  late Random rand;
  late List<int> notes;

  int? errorKey;

  @override
  void initState() {
    super.initState();

    rand = Random(DateTime.now().microsecondsSinceEpoch);
    notes = List.generate(songDuration.inSeconds * 20, (_) => rand.nextInt(4));
    print(notes);

    RawKeyboard.instance.addListener((value) {
      if (value is RawKeyDownEvent && keys.contains(value.character)) {
        int keyNumber = (int.parse(value.character!)-1);

        if (!songComplete && errorKey == null) {
          if (notes[selectedIndex] == keyNumber) {
            if (selectedIndex == 0) {
              startController.add(true);
            }

            setState(() {
              selectedIndex++;
            });

            scrollController.scrollTo(
              index: selectedIndex,
              duration: const Duration(milliseconds: 200),
              curve: Curves.ease,
            );
          } else {
            setState(() {
              errorKey = keyNumber;
            });

            Future.delayed(const Duration(seconds: 2), () => setState(() {
              errorKey = null;
            }));
          }
        }

        // TODO remove this if game mode is timed
        if (selectedIndex == notes.length) {
           setState(() {
            songComplete = true;
          });

          Future.delayed(Duration(seconds: 2), () => confettiController.play());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Builder(
      builder: (context) {
        Size screenSize = MediaQuery.of(context).size;
        keyHeight = (screenSize.height - 40) / 3;
        keyWidth = keyHeight * .75;

        return Focus(
          onKey: (FocusNode node, RawKeyEvent event) => KeyEventResult.handled,
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: Stack(
              children: [
                Center(
                  child: Row(
                    children: [
                      Container(
                        height: keyHeight * 3,
                        width: (keyWidth * 4) + 3,
                        color: Colors.black,
                        child:  ScrollablePositionedList.builder(
                          itemScrollController: scrollController,
                          itemCount: notes.length + 1,
                          shrinkWrap: true,
                          reverse: true,
                          itemBuilder: (context, index) =>
                            index == notes.length
                              ? Container(
                                  color: Colors.grey[50],
                                  width: keyWidth * 4,
                                  height: keyHeight * 3,
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [0, 1, 2, 3].map((i) =>
                                    PianoKey(
                                      isNote: notes[index] == i,
                                      isErrored: selectedIndex == index && errorKey == i,
                                      rowNumber: index,
                                      keyHeight: keyHeight,
                                      keyWidth: keyWidth,
                                    )
                                  ).toList(),
                                ),
                        ),
                      ),
                      TimerProgressBar(
                        duration: songDuration,
                        height: keyHeight * 3,
                        startStream: startController.stream,
                        onTimeout: () {
                          setState(() {
                            songComplete = true;
                          });

                          Future.delayed(Duration(seconds: 2), () => confettiController.play());

                          globals.get<ScoreDatabase>().addScore(Score(
                            playerInitials: 'KAM',
                            score: selectedIndex + 1,
                            recordedAt: DateTime.now(),
                          ));

                          Future.delayed(const Duration(seconds: 5), () {
                            Navigator.of(context).pushNamed("/leaderboard");
                          });
                        },
                      ),
                    ],
                  ),
                ),
                songComplete
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        color: Colors.lightGreen,
                        child: Text(
                          "You Win! ${selectedIndex+1} keys pressed",
                          style: const TextStyle(fontSize: 30),
                        ),
                      )
                    )
                  : const SizedBox(),

                Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    confettiController: confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ], // manually specify the colors to be used/ define a custom shape/path.
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
