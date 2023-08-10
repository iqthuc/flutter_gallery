abstract class AudioAction {
  Future<void> init();
  Future<void> play();
  Future<void> replay();
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
}
