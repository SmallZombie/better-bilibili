import 'package:better_bilibili/ui/core/bilibili/video_player/panel/settings/codec_selection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/subtitle_settings/subtitle_settings_panel.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue, useMaterial3: true),
      home: VideoPlayerPanelTest2(),
    ),
  );
}

class VideoPlayerPanelTest2 extends StatefulWidget {
  const VideoPlayerPanelTest2({super.key});

  @override
  State<VideoPlayerPanelTest2> createState() => _VideoPlayerPanelTest2State();
}

class _VideoPlayerPanelTest2State extends State<VideoPlayerPanelTest2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VideoPlayerPanelTest2')),
      body: Padding(
        padding: const .all(24.0),
        child: SingleChildScrollView(
          scrollDirection: .horizontal,
          child: Row(
            crossAxisAlignment: .start,
            spacing: 24.0,
            children: [
              // SizedBox(
              //   width: 320,
              //   height: 400,
              //   child: const PlaybackRatePanel(),
              // ),
              SizedBox(
                width: 320,
                height: 400,
                child: const SubtitleSettingsPanel(),
              ),
              // SizedBox(
              //   width: 320,
              //   height: 400,
              //   child: const QualityPanel(),
              // ),
              // SizedBox(
              //   width: 320,
              //   height: 400,
              //   child: const SettingsPanel(),
              // ),
              // SizedBox(
              //   width: 320,
              //   height: 400,
              //   child: const DanmakuSettingsPanel(),
              // ),
              SizedBox(
                width: 320,
                height: 400,
                child: const CodecSelectionPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
