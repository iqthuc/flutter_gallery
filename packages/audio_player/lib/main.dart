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
    final AudioController controller = AudioController(player: AudioPlayer());
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AudioWidget(
              controller: controller,
              audioPath:
                  "https://firebasestorage.googleapis.com/v0/b/fir-fcm-b44e3.appspot.com/o/mp3%2FGat-Di-Nuoc-Mat-Noo-Phuoc-Thinh-Tonny-Viet.mp3?alt=media&token=dca741cb-03b6-4ec0-bb6d-f4e0b772afdb",
            ),
          ],
        ),
      ),
    );
  }
}
