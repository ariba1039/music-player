import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicplayer/customListItem_widget.dart';
import 'package:musicplayer/main.dart';

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with WidgetsBindingObserver
// this will be for observing th life cycle of the app
{
  //initializing the variables

  late Duration duration;
  late Duration position;
  bool isPlaying = false;
  IconData btnIcon = Icons.play_arrow;

  late BaTumTss instance;
  late AudioPlayer audioPlayer;

  Box box = Hive.box<String>('myBox');

  String currentSong = "";
  String currentCover = "";
  String currentTitle = "";
  String currentSinger = "";
  String url = "";

  var index;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    instance = getIt<BaTumTss>();
    audioPlayer = instance.audio;
    duration = new Duration();
    position = new Duration();

    if (box.get('playedOnce') == "false") {
      // if the app is opened for the first time so no song has been played yet
      setState(() {
        currentCover = "https://www.youtube.com/watch?v=BC19kwABFwc";
        currentTitle = "choose a song to play";
      });
    } else if (box.get('playedOnce') == "true") {
      // if the user is opening the app second or third time he has already played the song
      currentCover = box.get('currentCover');
      currentSinger = box.get('currentSinger');
      currentTitle = box.get('currentTitle');
      url = box.get('url');
    }
  }

// adding observer for handling the instance of audioplayer according to the application
  @override
  void didChangeAppLifeCycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      audioPlayer.pause();
      setState(() {
        btnIcon = Icons.pause;
      });
    } else if (state == AppLifecycleState.resumed) {
      if (isPlaying == true) {
        audioPlayer.resume();

        setState(() {
          btnIcon = Icons.play_arrow;
        });
      }
    } else if (state == AppLifecycleState.detached) {
      audioPlayer.stop();
      audioPlayer.release();
    }
  }
  //disposing to save memory leaks

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
  //creating a list of song

  void playMusic(String url) async {
    if (isPlaying && currentSong != url) {
      audioPlayer.pause();
      int result = await audioPlayer.play(url);
      if (result == 1) {
        setState(() {
          currentSong = url;
        });
      } else if (!isPlaying) {
        int result = await audioPlayer.play(url);
        if (result == 1) {
          setState(() {
            isPlaying = true;
            btnIcon = Icons.play_arrow;
          });
        }
      }
      //setting the state of the duration /end points
      audioPlayer.onDurationChanged.listen((event) {
        setState(() {
          duration = event;
        });
      });
      audioPlayer.onAudioPositionChanged.listen((event) {
        setState(() {
          position = event;
        });
      });
    }

    @override
    Widget build(BuildContext context) {
      var music;
      return Scaffold(
        appBar: AppBar(
          title: Text("Music Player"),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) => customListItem(
                  title: music[index]['title'],
                  singer: music[index]['singer'],
                  cover: music[index]['coverUrl'],
                  onTap: () async {
                    setState(() {
                      currentTitle:
                      music[index]['title'];
                      currentSinger:
                      music[index]['singer'];
                      currentCover:
                      music[index]['coverUrl'];
                      url = music[index]['url'];
                    });

                    playMusic(url);
                    box.put('playedOnce', 'true');
                    box.put('currentCover', currentCover);
                    box.put('currentSinger', currentSinger);
                    box.put('currentTitle', currentTitle);
                    box.put('url', url);
                  }),
              itemCount: music.length,
            ),
            ),
 Container(decoration:BoxDecoration(color: Colors.white, boxShadow:BoxShadow(color: Color(0x55212121), 
 blurRadius: 8,)], ),
 child: Column(children: [Slider.adaptive(value: position.inSeconds.toDouble(), onChanged: (value)(seektoSecond))],),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
