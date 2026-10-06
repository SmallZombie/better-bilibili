import 'dart:async';

import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // timeDilation = 15.0;
  runApp(
    MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue, useMaterial3: true),
      home: ImageViewerTest1(),
    ),
  );
}

class ImageViewerTest1 extends StatefulWidget {
  const ImageViewerTest1({super.key});

  @override
  State<ImageViewerTest1> createState() => _ImageViewerTest1State();
}

class _ImageViewerTest1State extends State<ImageViewerTest1> {
  void _onTap() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ImageViewer(
            images: [
              ImageViewerItem(
                thumbUrl: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg@1052w',
                url: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg',
              ),
              ImageViewerItem(
                thumbUrl: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg@1052w',
                url: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg',
              ),
              ImageViewerItem(
                thumbUrl: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg@1052w',
                url: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg',
              ),
              ImageViewerItem(
                thumbUrl: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg@1052w',
                url: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg',
              ),
              ImageViewerItem(
                thumbUrl: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg@1052w',
                url: 'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg',
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImageViewerTest1'),
      ),
      body: Padding(
        padding: const .fromLTRB(20.0, 0.0, 0.0, 0.0),
        child: GestureDetector(
          onTap: _onTap,
          child: Hero(
            tag: 'ImageViewer_0',
            // curve: Curves.easeOutQuart,
            createRectTween: (begin, end) => RectTween(begin: begin, end: end),
            child: Image.network(
              'https://i2.hdslb.com/bfs/new_dyn/eb8acef7aac35d8356230a9bcdb1c782161775300.jpg@1052w',
              width: 1920 / 5,
              height: 1080 / 5,
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewerItem {
  final String thumbUrl;
  final String url;

  const ImageViewerItem({required this.thumbUrl, required this.url});
}

enum ImageViewerQualityEnum {
  origin,
  thumbnail,
}

class ImageViewer extends StatefulWidget {
  final ImageViewerQualityEnum defaultQuality;
  final List<ImageViewerItem> images;
  final int initialIndex;

  const ImageViewer({
    super.key,
    this.defaultQuality = ImageViewerQualityEnum.thumbnail,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;

  final Map<int, ImageViewerQualityEnum> _qualityStates = {};

  final TransformationController _transformationController = TransformationController();

  bool _isLoadingQuality = false;
  double _dragOffset = 0.0;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _transformationController.addListener(_onScaleChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onScaleChanged);
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  ImageViewerQualityEnum get _currentImageQuality => _qualityStates[_currentIndex] ?? widget.defaultQuality;

  void _onScaleChanged() {
    final isZoomed = _transformationController.value.getMaxScaleOnAxis() > 1.001;
    if (_isZoomed != isZoomed) {
      setState(() {
        _isZoomed = isZoomed;
      });
    }
  }

  Future<void> _toggleQuality() async {
    if (_isLoadingQuality) return;

    final nextQuality = _currentImageQuality == ImageViewerQualityEnum.thumbnail
        ? ImageViewerQualityEnum.origin
        : ImageViewerQualityEnum.thumbnail;

    setState(() => _isLoadingQuality = true);

    final imageUrl = nextQuality == ImageViewerQualityEnum.origin
        ? widget.images[_currentIndex].url
        : widget.images[_currentIndex].thumbUrl;

    try {
      final ImageProvider provider = NetworkImage(imageUrl);
      final completer = Completer<void>();
      final stream = provider.resolve(ImageConfiguration.empty);

      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, synchronousCall) {
          completer.complete();
          stream.removeListener(listener);
        },
        onError: (e, s) {
          completer.completeError(e);
          stream.removeListener(listener);
        },
      );

      stream.addListener(listener);
      await completer.future;
    } catch (e) {
      debugPrint('Load failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _qualityStates[_currentIndex] = nextQuality;
          _isLoadingQuality = false;
        });
      }
    }
  }

  void _handleScale(bool zoomIn) {
    double scale = _transformationController.value.getMaxScaleOnAxis();
    double newScale = zoomIn ? scale * 1.5 : scale / 1.5;
    _transformationController.value = Matrix4.identity()..scale(newScale.clamp(1.0, 5.0));
  }

  Widget _buildHeroFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final hero = (flightDirection == HeroFlightDirection.pop ? fromHeroContext.widget : toHeroContext.widget) as Hero;
    return hero.child;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Theme.of(context).platform == TargetPlatform.windows || Theme.of(context).platform == TargetPlatform.macOS;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutQuart),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutQuart),
        const SingleActivator(LogicalKeyboardKey.equal, control: true): () => _handleScale(true),
        const SingleActivator(LogicalKeyboardKey.minus, control: true): () => _handleScale(false),
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.pop(context),
      },
      child: Focus(
        autofocus: true,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: (1 - (_dragOffset.abs() / 500)).clamp(0.0, 1.0),
                  child: Container(color: Colors.black),
                ),
              ),

              Positioned.fill(
                child: GestureDetector(
                  onVerticalDragUpdate: _isZoomed
                      ? null
                      : (details) {
                          setState(() => _dragOffset += details.delta.dy);
                        },
                  onVerticalDragEnd: _isZoomed
                      ? null
                      : (details) {
                          if (_dragOffset.abs() > 150) {
                            Navigator.pop(context);
                          } else {
                            setState(() => _dragOffset = 0);
                          }
                        },
                  child: Transform.translate(
                    offset: Offset(0, _dragOffset),
                    child: PageView.builder(
                      controller: _pageController,
                      physics: _isZoomed ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                      itemCount: widget.images.length,
                      onPageChanged: (index) {
                        _transformationController.value = Matrix4.identity();
                        setState(() {
                          _currentIndex = index;
                          _dragOffset = 0;
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = widget.images[index];
                        final itemQuality = _qualityStates[index] ?? widget.defaultQuality;
                        final displayUrl = itemQuality == ImageViewerQualityEnum.origin ? item.url : item.thumbUrl;

                        return InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 1.0,
                          maxScale: 5.0,
                          child: Hero(
                            tag: 'ImageViewer_$index',
                            createRectTween: (begin, end) => RectTween(begin: begin, end: end),
                            flightShuttleBuilder: _buildHeroFlightShuttle,
                            child: SizedBox.expand(
                              child: ImageWapper(image: NetworkImage(displayUrl)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              _buildTopLeftBar(),
              _buildTopRightBar(),

              if (isDesktop) ...[
                if (_currentIndex > 0) _buildSideNav(isLeft: true),
                if (_currentIndex < widget.images.length - 1) _buildSideNav(isLeft: false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopLeftBar() {
    return Positioned(
      top: 16.0,
      left: 16.0,
      child: _CircleButton(
        icon: Icons.close,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildTopRightBar() {
    return Positioned(
      top: 16.0,
      right: 16.0,
      child: Row(
        children: [
          _isLoadingQuality
              ? Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const ShapeDecoration(
                    color: Colors.black54,
                    shape: StadiumBorder(),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                )
              : TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: _toggleQuality,
                  icon: Icon(_currentImageQuality == ImageViewerQualityEnum.origin ? Icons.hd : Icons.sd),
                  label: Text(_currentImageQuality == ImageViewerQualityEnum.origin ? '切换到缩略质量' : '切换到原始质量'),
                ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const ShapeDecoration(color: Colors.black54, shape: StadiumBorder()),
            child: Text('${_currentIndex + 1} / ${widget.images.length}', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          _CircleButton(icon: Icons.more_vert, onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSideNav({required bool isLeft}) {
    return Positioned(
      left: isLeft ? 20 : null,
      right: isLeft ? null : 20,
      top: 0,
      bottom: 0,
      child: Center(
        child: _CircleButton(
          icon: isLeft ? Icons.chevron_left : Icons.chevron_right,
          onPressed: () => isLeft
              ? _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut)
              : _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      child: IconButton(
        iconSize: 20,
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
