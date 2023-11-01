import 'package:audio_players/audio_action.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioController extends AudioAction {
  final AudioPlayer player;
  final ReleaseMode releaseMode;

  AudioController({
    required this.player,
    this.releaseMode = ReleaseMode.loop,
  });

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
