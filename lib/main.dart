import 'package:flutter/material.dart';
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
    );
  }
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

class _MyHomePageState extends State<MyHomePage> {
  ItemScrollController scrollController = ItemScrollController();
  int index = 0;
  bool songComplete = false;

  @override
  void initState() {
    super.initState();

    RawKeyboard.instance.addListener((value) {
      if (value is RawKeyDownEvent && keys.contains(value.character)) {
        if (!songComplete) {
          setState(() {
            index += 1;
          });
        }

        if (index == notes.length) {
           setState(() {
            songComplete = true;
          });
        }

        scrollController.scrollTo(index: index, duration: const Duration(milliseconds: 300));
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
    return Focus(
      onKey: (FocusNode node, RawKeyEvent event) => KeyEventResult.handled,
      autofocus: true,
      child: Scaffold(
        backgroundColor: songComplete ? Colors.green : Colors.white,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: ScrollablePositionedList.builder(
          itemScrollController: scrollController,
          itemCount: notes.length,
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (context, index) => 
            Row(
              children: [0, 1, 2, 3].map((i) =>
                Container(
                  color: notes[index] == i ? Colors.red : Colors.blue,
                  width: 100,
                  height: 175,
                  child: Text("r$index n${notes[index]} c$i"),
                )
              ).toList(),
            ),
        ),
      ),
    );
  }
}

const notes = [0, 1, 2, 3, 0, 1, 2, 3, 3, 2, 1, 0, 2, 2, 1, 0];
const keys = ["1", "2", "3", "4"];