import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';

late MyAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.app.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );

  runApp(
    MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue),
      home: const AudioServiceTest1(),
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final Player player = Player();

  MyAudioHandler() {
    player.setVolume(30.0);

    player.stream.playing.listen((playing) => _broadcastState());
    player.stream.position.listen((position) => _broadcastState());
    player.stream.buffer.listen((buffer) => _broadcastState());

    player.stream.duration.listen((duration) {
      _broadcastState();
      if (mediaItem.value != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }
    });

    player.stream.completed.listen((completed) {
      if (completed) {
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.completed,
            playing: false,
          ),
        );
      }
    });
  }

  void _broadcastState() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (player.state.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        playing: player.state.playing,
        updatePosition: player.state.position,
        bufferedPosition: player.state.buffer,
        processingState: AudioProcessingState.ready,
      ),
    );
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() async {
    await player.stop();
    return super.stop();
  }

  Future<void> loadMedia(MediaItem item, String url) async {
    mediaItem.add(item);
    await player.open(Media(url), play: false);
  }
}

class AudioServiceTest1 extends StatefulWidget {
  const AudioServiceTest1({super.key});

  @override
  State<AudioServiceTest1> createState() => _AudioServiceTest1State();
}

class _AudioServiceTest1State extends State<AudioServiceTest1> {
  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final item = MediaItem(
      id: 'shout_01',
      title: 'Sh0ut', // ShØut
      artist: 'SawanoHiroyuki[nZk] / Tielle / R!N/Gemie',
      artUri: Uri.parse(
        'http://192.168.5.100:12345/share/download?key=d0501b6cc495d7d45fabc87ddbe3427f6243604e71cabff683dbd3067bdfcd8b&code=87394',
      ),
    );

    await audioHandler.loadMedia(
      item,
      'http://192.168.5.100:12345/share/download?key=73406f447074239891e3ad297f6133d4b485d2fdf21242e74cb78e4da78dbc2e&code=16331',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AudioService & media_kit')),
      body: Center(
        child: StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'http://192.168.5.100:12345/share/download?key=d0501b6cc495d7d45fabc87ddbe3427f6243604e71cabff683dbd3067bdfcd8b&code=87394',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.music_note, size: 100),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 64,
                      icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                      onPressed: () {
                        if (playing) {
                          audioHandler.pause();
                        } else {
                          audioHandler.play();
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
