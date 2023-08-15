abstract class AudioAction {
  Future<void> init(String audioPath);
  Future<void> play(String audioPath);
  Future<void> replay(String audioPath);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
}
