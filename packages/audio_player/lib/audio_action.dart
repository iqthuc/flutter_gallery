import 'package:audioplayers/audioplayers.dart';

abstract class AudioAction {
  Future<void> initConfigPlayer();
  Future<void> play(Source source);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
  Future<void> backward({Duration interval});
  Future<void> forward({Duration interval});
  Future<void> playAt(double progressSelected);
}
