import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/save_image.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pasteboard/pasteboard.dart';

extension ImageViewer on BuildContext {
  /// [shouldUseOriginalQuality] 每次导航到新图片时被调用，
  /// 此回调用于指示图片查看器是否应该立即为其加载原始质量
  void openImageViewer(
    List<ImageViewerItem> images, {
    int initialIndex = 0,
    List<ImageViewerAction> Function(
      BuildContext context,
      ImageViewerItem image,
      int index,
      List<ImageViewerItem> images,
    )?
    actionsBuilder,
    bool Function(ImageViewerItem image)? shouldUseOriginalQuality,
  }) {
    assert(images.isNotEmpty);

    Navigator.of(this).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: null,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _ImageViewerScreen(
            images: images,
            initialIndex: initialIndex,
            actionsBuilder: actionsBuilder,
            shouldUseOriginalQuality: shouldUseOriginalQuality,
          );
        },
      ),
    );
  }

  static String getSaveDateString(BuildContext context) {
    final now = DateTime.now();
    return '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}_${now.second.toString().padLeft(2, '0')}';
  }
}

class ImageViewerItem {
  final String url;
  final String thumbUrl;
  final String? heroTag;
  final int width;
  final int height;

  const ImageViewerItem({
    required this.url,
    required this.thumbUrl,
    this.heroTag,
    required this.width,
    required this.height,
  });
}

class ImageViewerAction {
  final String name;
  final String? description;
  final IconData? icon;
  final VoidCallback onTap;

  const ImageViewerAction({
    required this.name,
    this.description,
    this.icon,
    required this.onTap,
  });
}

class _ImageViewerScreen extends StatefulWidget {
  final List<ImageViewerItem> images;
  final int initialIndex;
  final List<ImageViewerAction> Function(
    BuildContext context,
    ImageViewerItem image,
    int index,
    List<ImageViewerItem> images,
  )?
  actionsBuilder;
  final bool Function(ImageViewerItem image)? shouldUseOriginalQuality;

  const _ImageViewerScreen({
    required this.images,
    required this.initialIndex,
    required this.actionsBuilder,
    this.shouldUseOriginalQuality,
  });

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> with SingleTickerProviderStateMixin {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'ImageViewerScreen'));

  List<ImageViewerItem> get images => widget.images;
  int get initialIndex => widget.initialIndex;

  late final AnimationController controller;
  late final PageController pageController;
  late final List<ImageViewerAction> _defaultActions;

  List<ImageViewerAction> get actions => [
    ..._defaultActions,
    if (widget.actionsBuilder != null) ...widget.actionsBuilder!(context, images[pageIndex], pageIndex, images),
  ];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..forward();

    pageController = PageController(initialPage: initialIndex);
    pageIndex = initialIndex;

    _defaultActions = [
      ImageViewerAction(
        name: '复制',
        icon: Icons.copy,
        onTap: () async {
          final client = Dio();
          try {
            final resp = await client.get(images[pageIndex].url, options: Options(responseType: .bytes));
            if (!mounted) return;

            await Pasteboard.writeImage(Uint8List.fromList(resp.data as List<int>));
            if (!mounted) return;

            context.showInfo('已复制');
          } on DioException catch (e) {
            context.showError('复制失败: ${e.response == null ? '未知错误' : '${e.response!.statusCode} ${e.message}'}');
          } catch (e, s) {
            _log.e(e, stackTrace: s);
          } finally {
            client.close();
          }
        },
      ),
      ImageViewerAction(
        name: '保存到本地',
        icon: Icons.download,
        onTap: () {
          final ext = images[pageIndex].url.split('.').last;
          context.saveImage(images[pageIndex].url, 'bilibili_${ImageViewer.getSaveDateString(context)}', ext);
        },
      ),
      if (images.length > 1)
        ImageViewerAction(
          name: '保存全部${images.length}张到本地',
          icon: Icons.download,
          onTap: () {
            final List<String> urls = [];
            final List<String> names = [];
            final List<String> exts = [];

            final dateStr = ImageViewer.getSaveDateString(context);
            for (int i = 0; i < images.length; i++) {
              final image = images[i];
              urls.add(image.url);
              names.add('bilibili_${dateStr}_${i + 1}');
              exts.add(image.url.split('.').last);
            }

            context.saveImages(urls, names, exts);
          },
        ),
    ];

    final useOriginalQuality = widget.shouldUseOriginalQuality?.call(images[0]) ?? false;
    if (useOriginalQuality) {
      _originalImageSet.add(0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    pageController.dispose();

    super.dispose();
  }

  void close() {
    controller.reverse();
    // context.pop();
    Navigator.pop(context);
  }

  int pageIndex = 0;

  void _setPage(int page) {
    setState(() {
      pageIndex = page;
      if (widget.shouldUseOriginalQuality?.call(images[page]) ?? false) {
        setState(() => _originalImageSet.add(page));
      }
    });
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int event) {
    if (event == pageIndex) return;
    setState(() {
      pageIndex = event;
      if (widget.shouldUseOriginalQuality?.call(images[event]) ?? false) {
        _originalImageSet.add(event);
      }
    });
  }

  final Set<int> _originalImageSet = {};

  void _viewOriginalImage(int index) {
    setState(() => _originalImageSet.add(index));
  }

  void _showMoreOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => BottomSheetWapper(
        child: ListView(
          children: actions.map((v) {
            return ListTile(
              leading: v.icon != null ? Icon(v.icon!) : null,
              title: Text(v.name),
              subtitle: v.description != null ? Text(v.description!) : null,
              onTap: () {
                // context.pop();
                Navigator.pop(context);
                v.onTap();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) => ColoredBox(
                color: Color.lerp(
                  Colors.transparent,
                  Colors.black,
                  controller.value,
                )!,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) => Opacity(
              opacity: controller.value,
              child: child,
            ),
            child: PageView(
              controller: pageController,
              onPageChanged: _onPageChanged,
              children: [
                for (int i = 0; i < images.length; i++)
                  _ImagePage(
                    image: images[i],
                    useHighQuality: _originalImageSet.contains(i),
                    controller: controller,
                    onClose: close,
                    onSecondaryTap: _showMoreOptionsSheet,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) => Opacity(
                opacity: controller.value,
                child: child,
              ),
              child: _buildTopLeft(),
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) => Opacity(
                opacity: controller.value,
                child: child,
              ),
              child: _buildTopRight(),
            ),
          ),
          if (pageIndex > 0)
            Positioned(
              top: 0,
              bottom: 0,
              left: 16.0,
              child: Center(child: _buildLeft()),
            ),
          if (pageIndex < images.length - 1)
            Positioned(
              top: 0,
              bottom: 0,
              right: 16.0,
              child: Center(child: _buildRight()),
            ),
        ],
      ),
    );
  }

  Widget _buildTopLeft() {
    return IconButton(
      color: const Color(0xffffffff),
      onPressed: close,
      icon: const Icon(Icons.close),
      style: IconButton.styleFrom(backgroundColor: Colors.black45),
    );
  }

  Widget _buildTopRight() {
    return Row(
      spacing: 12.0,
      children: [
        if (!_originalImageSet.contains(pageIndex))
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: const Color(0xffffffff),
              shape: const StadiumBorder(),
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => _viewOriginalImage(pageIndex),
            icon: Icon(Icons.hd),
            label: Text('查看原图'),
          ),
        Container(
          alignment: .center,
          padding: const .symmetric(horizontal: 16.0, vertical: 6.0),
          decoration: const ShapeDecoration(color: Colors.black45, shape: StadiumBorder()),
          child: Text(
            '${pageIndex + 1} / ${images.length}',
            style: const TextStyle(color: Color(0xffffffff)),
          ),
        ),
        IconButton(
          color: const Color(0xffffffff),
          onPressed: _showMoreOptionsSheet,
          icon: const Icon(Icons.more_horiz),
          style: IconButton.styleFrom(backgroundColor: Colors.black45),
        ),
      ],
    );
  }

  Widget _buildLeft() {
    return IconButton(
      color: const Color(0xffffffff),
      onPressed: () {
        _setPage(pageIndex - 1);
      },
      icon: const Icon(Icons.arrow_left_rounded, size: 32.0),
    );
  }

  Widget _buildRight() {
    return IconButton(
      color: const Color(0xffffffff),
      onPressed: () {
        _setPage(pageIndex + 1);
      },
      icon: const Icon(Icons.arrow_right_rounded, size: 32.0),
    );
  }
}

class _ImagePage extends StatefulWidget {
  final ImageViewerItem image;
  final bool useHighQuality;
  final AnimationController controller;
  final VoidCallback onClose;
  final VoidCallback onSecondaryTap;

  const _ImagePage({
    required this.image,
    required this.useHighQuality,
    required this.controller,
    required this.onClose,
    required this.onSecondaryTap,
  });

  @override
  State<_ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<_ImagePage> {
  ImageViewerItem get image => widget.image;
  bool get useHighQuality => widget.useHighQuality;
  AnimationController get controller => widget.controller;

  late final TransformationController transformationController;

  Future? pending;

  @override
  void initState() {
    super.initState();

    transformationController = TransformationController();
    transformationController.addListener(_onScaleChanged);
  }

  @override
  void dispose() {
    super.dispose();

    transformationController.removeListener(_onScaleChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (useHighQuality) {
      pending ??= _loadOriginalImage();
    }
  }

  @override
  void didUpdateWidget(covariant _ImagePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.useHighQuality != useHighQuality) {
      pending ??= _loadOriginalImage();
    }
  }

  bool _showHighQuality = false;

  Future<void> _loadOriginalImage() async {
    await precacheImage(NetworkImage(image.url), context);
    if (!mounted) return;

    setState(() => _showHighQuality = true);
  }

  bool _isZoomed = false;

  void _onScaleChanged() {
    final isZoomed = transformationController.value.getMaxScaleOnAxis() > 1;
    if (_isZoomed != isZoomed) {
      setState(() {
        _isZoomed = isZoomed;
      });
    }
  }

  bool _dragging = false;
  Offset _dragOffset = .zero;

  // 拖动距离到达此值时完全隐藏背景遮罩
  double _dragHideMaskDistance = 0.0;

  // 拖动距离超过此值时视为关闭
  final double _dragCloseDistance = 240.0;

  void _onPointerDown(PointerDownEvent event) {
    if ((event.buttons & kSecondaryButton) != 0) return;
    if (_isZoomed) return;

    controller.stop();

    final viewport = MediaQuery.sizeOf(context);
    _dragHideMaskDistance = viewport.longestSide * 1.25;

    _dragging = true;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isZoomed || !_dragging) return;

    setState(() {
      _dragOffset = _dragOffset += event.delta;
    });

    final closeProgress = 1 - (_dragOffset.distance / _dragHideMaskDistance).clamp(0.0, 1.0);
    controller.value = closeProgress;
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isZoomed || !_dragging) return;

    if (_dragOffset.distance > _dragCloseDistance) {
      widget.onClose();
    } else {
      setState(() {
        _dragOffset = .zero;
        _dragging = false;
      });
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: GestureDetector(
        behavior: .translucent,
        onSecondaryTap: widget.onSecondaryTap,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(
            begin: _dragging ? .zero : _dragOffset,
            end: _dragging ? _dragOffset : .zero,
          ),
          duration: _dragging ? .zero : const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(offset: value, child: child);
          },
          child: InteractiveViewer(
            transformationController: transformationController,
            minScale: 1.0,
            maxScale: 5.0,
            child: Center(
              child: Hero(
                tag: image.thumbUrl,
                createRectTween: (begin, end) => _CurvedRectTween(
                  begin: begin,
                  end: end,
                  curve: Curves.easeOutCubic,
                ),
                child: Stack(
                  alignment: .center,
                  children: [
                    ImageWapper(
                      image: NetworkImage(_showHighQuality ? image.url : image.thumbUrl),
                      fit: .contain,
                    ),
                    if (!_showHighQuality && useHighQuality) CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurvedRectTween extends RectTween {
  _CurvedRectTween({
    super.begin,
    super.end,
    required this.curve,
  });

  final Curve curve;

  @override
  Rect? lerp(double t) => super.lerp(curve.transform(t));
}
