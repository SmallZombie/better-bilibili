import 'package:better_bilibili/ui/core/bilibili/video_player/notice/notice_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/notice/notice_layer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: NoticeTest1(),
    ),
  );
}

class NoticeTest1 extends StatefulWidget {
  const NoticeTest1({super.key});

  @override
  State<NoticeTest1> createState() => _NoticeTest1State();
}

class _NoticeTest1State extends State<NoticeTest1> {
  final NoticeController controller = NoticeController();

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoticeTest1'),
      ),
      body: Center(
        child: Container(
          width: 1920 / 2,
          height: 1080 / 2,
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: .circular(10),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 16,
                bottom: 16,
                child: NoticeLayer(controller: controller),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: TextButton(
                  onPressed: () {
                    controller.show(
                      Notice(
                        content: Text('awa? ${++counter}'),
                        action: '撤销',
                        onTap: (notice) {
                          controller.dismiss(notice);
                        },
                      ),
                    );
                  },
                  child: Text('Create notice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
