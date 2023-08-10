import 'package:audio_players/audio_action.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioController extends AudioAction {
  final AudioPlayer player;
  final String audioPath;
  final ReleaseMode? releaseMode;

  AudioController({
    AudioPlayer? audioPlayer,
    required this.audioPath,
    this.releaseMode = ReleaseMode.stop,
  }) : player = audioPlayer ?? AudioPlayer();

  @override
  Future<void> init() async {
    await player.setSourceUrl(audioPath).catchError(
          (error) => debugPrint('[AudioController] errors: $error'),
        );
  }

  @override
  Future<void> play() async {
    await player.play(UrlSource(audioPath));
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
  Future<void> replay() async {
    await player.stop();
    await player.play(UrlSource(audioPath));
  }

  @override
  Future<void> dispose() async {
    await player.dispose();
  }
}
