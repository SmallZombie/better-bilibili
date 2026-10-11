import 'package:better_bilibili/ui/core/share/image_viewer.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(MaterialApp(home: ImageViewerTest2()));
}

const data1 = [
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image1.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image1_low.jpg',
    width: 2560,
    height: 1811,
  ),
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image2.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image2_low.jpg',
    width: 2560,
    height: 2560,
  ),
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image3.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image3_low.jpg',
    width: 1544,
    height: 2560,
  ),
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image4.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image4_low.jpg',
    width: 1806,
    height: 2560,
  ),
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image5.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image5_low.jpg',
    width: 3840,
    height: 2160,
  ),
];

const data2 = [
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image6.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image6_low.jpg',
    width: 2508,
    height: 1771,
  ),
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image7.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image7_low.jpg',
    width: 640,
    height: 640,
  ),
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image8.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image8_low.jpg',
    width: 1807,
    height: 2560,
  ),
  ImageViewerItem(
    url: 'http://127.0.0.1:5500/test/assets/images/image9.jpg',
    thumbUrl: 'http://127.0.0.1:5500/test/assets/images/image9_low.jpg',
    width: 1595,
    height: 2560,
  ),
];

class ImageViewerTest2 extends StatefulWidget {
  const ImageViewerTest2({super.key});

  @override
  State<ImageViewerTest2> createState() => _ImageViewerTest2State();
}

class _ImageViewerTest2State extends State<ImageViewerTest2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImageViewerTest2'),
      ),
      body: Column(
        crossAxisAlignment: .start,
        children: [
          // 有 hero
          Padding(
            padding: const .only(left: 100, top: 100),
            child: Row(
              mainAxisSize: .min,
              children: data1.map((v) {
                return InkWell(
                  onTap: () => context.openImageViewer(
                    data1,
                    initialIndex: data1.indexOf(v),
                  ),
                  child: Hero(
                    tag: v.thumbUrl,
                    child: ImageWapper(image: NetworkImage(v.thumbUrl), height: 200),
                  ),
                );
              }).toList(),
            ),
          ),
          // 无 hero
          Padding(
            padding: const .only(left: 100, top: 100),
            child: Row(
              mainAxisSize: .min,
              children: data2.map((v) {
                return InkWell(
                  onTap: () => context.openImageViewer(
                    data2,
                    initialIndex: data2.indexOf(v),
                  ),
                  child: ImageWapper(image: NetworkImage(v.thumbUrl), height: 200),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
