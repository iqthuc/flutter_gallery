import 'package:audio_players/audio_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioWidget extends StatefulWidget {
  const AudioWidget({
    super.key,
    required this.controller,
    required this.audioPath,
  });

  final String audioPath;
  final AudioController controller;
  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  ValueNotifier<Duration> totalTime = ValueNotifier(Duration.zero);
  ValueNotifier<Duration> currentPosition = ValueNotifier(Duration.zero);
  ValueNotifier<double> currentProgress = ValueNotifier(0);
  bool isSliding = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initPlayer();
    });
  }

  initPlayer() async {
    await widget.controller.player.setSourceUrl(widget.audioPath);
    await widget.controller.play(widget.audioPath);

    totalTime.value = await widget.controller.player.getDuration() ?? Duration.zero;

    widget.controller.player.onPlayerStateChanged.listen((playerState) {
      if (playerState == PlayerState.stopped) {
        currentPosition.value = Duration.zero;
      }
    });

    widget.controller.player.onPositionChanged.listen((position) {
      currentPosition.value = position;
      if (isSliding == false) {
        currentProgress.value = currentPosition.value.inMilliseconds / totalTime.value.inMilliseconds;
      }
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder(
                      valueListenable: currentPosition,
                      builder: (context, value, _) {
                        return Text(value.format);
                      }),
                  Expanded(
                    child: ValueListenableBuilder(
                        valueListenable: currentProgress,
                        builder: (context, value, _) {
                          return Slider(
                            value: value,
                            onChanged: (value) {
                              isSliding = true;
                              currentProgress.value = value;
                            },
                            onChangeEnd: (value) async {
                              isSliding = false;
                              await widget.controller.playAt(value);
                            },
                          );
                        }),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: totalTime,
              builder: (context, value, _) {
                return Text(value.format);
              },
            ),
          ],
        ),
        TextButton(
          onPressed: () async {
            widget.controller.play(widget.audioPath);
          },
          child: const Text("start"),
        ),
        TextButton(
          onPressed: () {
            widget.controller.player.pause();
          },
          child: const Text("pause"),
        ),
        TextButton(
          onPressed: () {
            widget.controller.player.resume();
          },
          child: const Text("resume"),
        ),
        TextButton(
          onPressed: () async {
            await widget.controller.player.stop();
            setState(() {});
          },
          child: const Text("stop"),
        ),
        TextButton(
          onPressed: () async {
            await widget.controller.backward();
          },
          child: const Text("backward 10s"),
        ),
        TextButton(
          onPressed: () async {
            await widget.controller.forward();
          },
          child: const Text("forward 10s"),
        ),
      ],
    );
  }
}

extension on Duration {
  String get format {
    int minutes = inMinutes.remainder(60);
    int seconds = inSeconds.remainder(60);
    String formattedDuration = '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
    return formattedDuration;
  }
}
