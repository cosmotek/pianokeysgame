
import 'dart:async';

import 'package:flutter/material.dart';

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

class TimerProgressBarState extends State<TimerProgressBar> with SingleTickerProviderStateMixin {
  late int totalTicks;
  late int ticks;

  late AnimationController colorController;

  late StreamController<double> positionStream;

  @override
  void initState() {
    super.initState();

    totalTicks = widget.duration.inMilliseconds ~/ widget.tickSpeed.inMilliseconds;
    ticks = totalTicks;
    positionStream = StreamController<double>();

    colorController = AnimationController(duration: widget.duration, vsync: this);

    positionStream.add(1.0);
    widget.startStream.listen((started) {
      if (started) {
        colorController.forward();

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
              valueColor: ColorTween(begin: Colors.lightBlue, end: Colors.red).animate(colorController),
            )
          );
        },
      ),
    );
  }
}
