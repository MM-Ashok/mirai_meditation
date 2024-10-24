import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioService._internal();

  Future<void> play(String url) async {
    // Stop the current audio if it's playing
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
    }
    // Set the new audio source and play
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // Optional: You can also add more functionality like pause, resume, etc.
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }
}
