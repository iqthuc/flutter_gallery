import 'package:audio_players/audio_action.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioController extends AudioAction {
  final AudioPlayer player;
  final ReleaseMode releaseMode;

  AudioController({
    required this.player,
    this.releaseMode = ReleaseMode.loop,
  });

  @override
  Future<void> init(String audioPath) async {
    await player.setSourceUrl(audioPath).catchError(
          (error) => debugPrint('[AudioController] errors: $error'),
        );
    player.setReleaseMode(releaseMode);
  }

  @override
  Future<void> play(String audioPath) async {
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
  Future<void> replay(String audioPath) async {
    await player.stop();
    await player.play(UrlSource(audioPath));
  }

  @override
  Future<void> dispose() async {
    await player.dispose();
  }
}
