import 'package:audio_players/audio_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: AudioWidget(
            audioPath:
                "https://firebasestorage.googleapis.com/v0/b/fir-fcm-b44e3.appspot.com/o/mp3%2FNhu-Nhung-Phut-Ban-Dau-Hoai-Lam.mp3?alt=media&token=ea3baf3c-3034-402c-8287-7119a446b9f8",
          ),
        ),
      ),
    );
  }
}
