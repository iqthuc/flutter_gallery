import 'package:audio_players/audio_action.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioController extends AudioAction {
  final AudioPlayer player;
  final ReleaseMode releaseMode;
  final Source initSource;

  AudioController({
    required this.player,
    this.releaseMode = ReleaseMode.loop,
    required this.initSource,
  });

  ///tổng thời gian của audio
  final ValueNotifier<Duration> totalTime = ValueNotifier(Duration.zero);

  /// [thời gian đang phát của audio
  final ValueNotifier<Duration> currentPosition = ValueNotifier(Duration.zero);

  /// % thời gian đang được phát của audio
  final ValueNotifier<double> currentProgress = ValueNotifier(0.0);
  
  /// tạm dừng thay đổi position trong một số trường hợp đặc biệt (ví dụ như đang trượt Slider)
  bool shouldChangePosition = true;

  @override
  Future<void> initConfigPlayer() async {
    await player.setSource(initSource);
    await player.setReleaseMode(releaseMode);
    totalTime.value = await player.getDuration() ?? Duration.zero;
    player.onPlayerStateChanged.listen((playerState) {
      if (playerState == PlayerState.stopped) {
        currentPosition.value = Duration.zero;
        currentProgress.value = 0;
      }
    });
    player.onPositionChanged.listen((position) {
      currentPosition.value = position;
      if (totalTime.value.inMilliseconds != 0 && shouldChangePosition) {
        currentProgress.value = currentPosition.value.inMilliseconds / totalTime.value.inMilliseconds;
      }
    });
  }

  @override
  Future<void> play(Source source) async {
    await player.play(source);
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> resume() async {
    await player.resume();
  }

  @override
  Future<void> stop() async {
    await player.stop();
  }

  @override
  Future<void> dispose() async {
    await player.dispose();
  }

  @override
  Future<void> backward({Duration interval = const Duration(seconds: 10)}) async {
    final currentPosition = await player.getCurrentPosition() ?? Duration.zero;
    final afterPosition = currentPosition <= interval ? Duration.zero : currentPosition - interval;
    await player.seek(afterPosition);
  }

  @override
  Future<void> forward({Duration interval = const Duration(seconds: 10)}) async {
    final currentPosition = await player.getCurrentPosition() ?? Duration.zero;
    final totalTime = await player.getDuration() ?? Duration.zero;
    final afterPosition = currentPosition >= (totalTime - interval) ? totalTime : currentPosition + interval;
    await player.seek(afterPosition);
  }

  @override
  Future<void> playAt(double progressSelected) async {
    final totalTime = await player.getDuration() ?? Duration.zero;
    final toProgress = Duration(seconds: (totalTime.inSeconds * progressSelected).toInt());
    await player.seek(toProgress);
  }
}
