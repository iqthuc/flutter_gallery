import 'package:audio_players/audio_controller.dart';
import 'package:flutter/material.dart';

class AudioWidget extends StatefulWidget {
  const AudioWidget({
    super.key,
    AudioController? controller,
    required this.audioPath,
  });

  final String audioPath;

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  late AudioController controller;
  @override
  void initState() {
    super.initState();
    controller = AudioController(audioPath: widget.audioPath);
    controller.init();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(value: 0.3, onChanged: (value) {}),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
                future: controller.player.getDuration(),
                builder: (context, data) {
                  return Text('0/${data.data?.inSeconds}');
                }),
          ],
        ),
        TextButton(
          onPressed: () async {
            controller.play();
          },
          child: const Text("start"),
        ),
        TextButton(
          onPressed: () {
            controller.player.pause();
          },
          child: const Text("pause"),
        ),
        TextButton(
          onPressed: () {
            controller.player.resume();
          },
          child: const Text("resume"),
        ),
        TextButton(
          onPressed: () {
            controller.player.stop();
          },
          child: const Text("stop"),
        ),
      ],
    );
  }
}
