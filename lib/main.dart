import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

const notes = [0, 1, 2, 3, 0, 1, 2, 3, 3, 2, 1, 0, 2, 2, 1, 0];
const keys = ["1", "2", "3", "4"];
const songDuration = Duration(seconds: 10);

class _MyHomePageState extends State<MyHomePage> {
  ItemScrollController scrollController = ItemScrollController();
  StreamController<bool> startController = StreamController<bool>();

  int index = 0;
  bool songComplete = false;

  double keyHeight = 175;
  double keyWidth = 100;

  @override
  void initState() {
    super.initState();

    RawKeyboard.instance.addListener((value) {
      if (value is RawKeyDownEvent && keys.contains(value.character)) {
        if (!songComplete) {
          if (index == 0) {
            startController.add(true);
          }

          setState(() {
            index++;
          });
        }

        if (index == notes.length) {
           setState(() {
            songComplete = true;
          });
        }

        scrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
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
                        },
                      ),
                    ],
                  ),
                ),
                songComplete
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Text(
                          "You Win! $index keys pressed",
                          style: const TextStyle(fontSize: 30),
                        ),
                      )
                    )
                  : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget PianoKey({ required bool isNote, required int rowNumber, double keyWidth = 100, double keyHeight = 175 }) =>
  Container(
    margin: const EdgeInsets.only(
      bottom: 0.5,
      left: 0.3,
      right: 0.3,
    ),
    padding: EdgeInsets.only(
      top: 0,
      left: keyWidth * .03,
      right: keyWidth * .03,
      bottom: keyHeight * .05,
    ),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(5),
        bottomRight: Radius.circular(5),
      ),
      color: isNote
        ? Colors.blue
        : Colors.grey[100],
    ),
    width: keyWidth,
    height: keyHeight,
    child: Container(
      width: keyWidth,
      height: keyHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        color: isNote
          ? Colors.lightBlue
          : Colors.white,
      ),
      child: (rowNumber == 0  && isNote)
        ? const Center(child: Text(
            "START",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )
          ))
        : null,
    ),
  );

class TimerProgressBar extends StatefulWidget {
  final Duration duration;
  final Duration tickSpeed;
  final double height;
  final Function onTimeout;
  final Stream<bool> startStream;

  const TimerProgressBar({
    Key? key, 
    required this.duration,
    this.tickSpeed = const Duration(milliseconds: 5),
    this.height = 200,
    required this.onTimeout,
    required this.startStream,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TimerProgressBarState();
}

class TimerProgressBarState extends State<TimerProgressBar> {
  late int totalTicks;
  late int ticks;

  late StreamController<double> positionStream;

  @override
  void initState() {
    super.initState();

    totalTicks = widget.duration.inMilliseconds ~/ widget.tickSpeed.inMilliseconds;
    ticks = totalTicks;
    positionStream = StreamController<double>();

    positionStream.add(1.0);
    widget.startStream.listen((started) {
      if (started) {
        Timer.periodic(widget.tickSpeed, (timer) {
          if (ticks <= 0) {
            timer.cancel();
            widget.onTimeout();
          } else {
            ticks -= 1;
            positionStream.add(ticks / totalTicks);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -1,
      child: StreamBuilder(
        stream: positionStream.stream,
        builder: (context, stream) { 
          return SizedBox(
            height: 20,
            width: widget.height,
            child: LinearProgressIndicator(
              value: (stream.data as double?) ?? 0,
              minHeight: 20,
            )
          );
        },
      ),
    );
  }
}