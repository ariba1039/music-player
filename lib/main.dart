import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:musicplayer/musicPlayerScreen.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  //for binding all the widgets
  WidgetsFlutterBinding.ensureInitialized();

  //this function will create a single instance of audio player throughout the app
  setUp();
// getting the directory where the app stores the data

  Directory dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox<String>('myBox');

  Box box = Hive.box<String>('myBox');

  if (box.get('playedOnce') == null) {
    box.put('playedOnce', "false");
  }
// this will state that none of the song has been played

  runApp(MyApp());
}

final getIt = GetIt.instance;

class BaTumTss {
  //initializing these two different variables will generate
  AudioPlayer _audio = AudioPlayer();
  AudioPlayer get audio => _audio;
}

void setUp() {
  getIt.registerFactory(() => BaTumTss());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MusicPlayerScreen(),
    );
  }
}
