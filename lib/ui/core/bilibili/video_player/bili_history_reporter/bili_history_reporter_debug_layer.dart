import 'package:better_bilibili/ui/core/bilibili/video_player/bili_history_reporter/bili_history_reporter.dart';
import 'package:flutter/material.dart';

class BiliHistoryReporterDebugLayer extends StatelessWidget {
  final BiliHistoryReporter controller;

  const BiliHistoryReporterDebugLayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DefaultTextStyle.merge(
        style: TextStyle(color: Colors.white, fontSize: 18.0),
        child: ColoredBox(
          color: Colors.black.withAlpha(150),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
              stream: controller.changeStream,
              builder: (context, _) {
                return Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text('playing: ${controller.playing}'),
                    Text('timer: ${controller.timer != null ? 'Activate' : null}'),
                    Text('heartbeatCounter: ${controller.heartbeatCounter}'),
                    Text('firstPlaybackTime: ${controller.firstPlaybackTime}'),
                    Text('realPlaybackTime: ${controller.realPlaybackTime}'),
                    Text('lastStartPlaybackPositon: ${controller.lastStartPlaybackPositon}'),
                    Text('duration: ${controller.duration}'),
                    Text('position: ${controller.position}'),
                    Text('maxPosition: ${controller.maxPosition}'),
                    Text('fileName: ${controller.fileName}'),
                    Text('isFirstPlay: ${controller.isFirstPlay}'),
                    Text('watchTime: ${controller.position - controller.lastStartPlaybackPositon}'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
