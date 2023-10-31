import 'package:audio_players/audio_controller.dart';
import 'package:audio_players/audio_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioController controller = AudioController(player: AudioPlayer(),releaseMode: ReleaseMode.stop);
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioWidget(
              controller: controller,
              audioPath:
                  "https://127.0.0.1:3060/home/test-mp3",
            ),
          ],
        ),
      ),
    );
  }
}
