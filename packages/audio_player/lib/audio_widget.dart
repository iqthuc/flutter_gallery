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
  Duration totalTime = Duration.zero;
  Duration position = Duration.zero;
  double progress = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.init(widget.audioPath);
    widget.controller.play(widget.audioPath);
    widget.controller.player.getDuration().then((value) => totalTime = value!);
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
              child: StreamBuilder<Duration>(
                  initialData: Duration.zero,
                  stream: widget.controller.player.onPositionChanged,
                  builder: (context, snapshot) {
                    position = snapshot.data ?? Duration.zero;

                    if (widget.controller.player.state == PlayerState.stopped) {
                      position = Duration.zero;
                    } else if (widget.controller.player.state == PlayerState.completed) {}

                    if (totalTime != Duration.zero && position != Duration.zero) {
                      progress = position.inMilliseconds / totalTime.inMilliseconds;
                    } else {
                      progress = 0;
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(position.format),
                        Expanded(
                          child: Slider(
                            value: progress,
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            StreamBuilder<Duration>(
                initialData: const Duration(),
                stream: widget.controller.player.onDurationChanged,
                builder: (context, snapshot) {
                  totalTime = snapshot.data ?? Duration.zero;
                  return Text(totalTime.format);
                }),
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
            final currentPosition = await widget.controller.player.getCurrentPosition() ?? Duration.zero;
            final afterPosition = Duration(
                milliseconds:
                    currentPosition.inMilliseconds <= 10 * 1000 ? 0 : currentPosition.inMilliseconds - 10 * 1000);

            await widget.controller.player.seek(afterPosition);
          },
          child: const Text("backward 10s"),
        ),
        TextButton(
          onPressed: () async {
            final currentPosition = await widget.controller.player.getCurrentPosition() ?? Duration.zero;
            final duration = await widget.controller.player.getDuration() ?? Duration.zero;
            final afterPosition = Duration(
                milliseconds: currentPosition.inMilliseconds >= duration.inMilliseconds - 10 * 1000
                    ? duration.inMilliseconds
                    : currentPosition.inMilliseconds + 10 * 1000);

            await widget.controller.player.seek(afterPosition);
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
