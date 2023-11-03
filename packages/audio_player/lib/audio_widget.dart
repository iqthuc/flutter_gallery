import 'package:audio_players/audio_controller.dart';
import 'package:flutter/material.dart';

class AudioWidget extends StatefulWidget {
  const AudioWidget({
    super.key,
    required this.controller,
  });

  final AudioController controller;
  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.controller.initConfigPlayer();
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
                      valueListenable: widget.controller.currentPosition,
                      builder: (context, value, _) {
                        return Text(value.format);
                      }),
                  Expanded(
                    child: ValueListenableBuilder(
                        valueListenable: widget.controller.currentProgress,
                        builder: (context, value, _) {
                          return Slider(
                            value: value,
                            onChanged: (value) {
                              widget.controller.shouldChangePosition = false;
                              widget.controller.currentProgress.value = value;
                            },
                            onChangeEnd: (value) async {
                              widget.controller.shouldChangePosition = true;
                              await widget.controller.playAt(value);
                            },
                          );
                        }),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: widget.controller.totalTime,
              builder: (context, value, _) {
                return Text(value.format);
              },
            ),
          ],
        ),
        TextButton(
          onPressed: () async {
            widget.controller.play(widget.controller.initSource);
          },
          child: const Text("start"),
        ),
        TextButton(
          onPressed: () {
            widget.controller.pause();
          },
          child: const Text("pause"),
        ),
        TextButton(
          onPressed: () {
            widget.controller.resume();
          },
          child: const Text("resume"),
        ),
        TextButton(
          onPressed: () async {
            await widget.controller.stop();
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
