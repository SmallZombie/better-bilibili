import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class AppTitleBar extends StatefulWidget {
  const AppTitleBar({super.key});

  static const height = 36.0;

  @override
  State<AppTitleBar> createState() => _AppTitleBarState();
}

class _AppTitleBarState extends State<AppTitleBar> with WindowListener {
  var _isMaximized = false;

  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);
    _syncMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);

    super.dispose();
  }

  @override
  void onWindowMaximize() {
    _setMaximized(true);
  }

  @override
  void onWindowUnmaximize() {
    _setMaximized(false);
  }

  @override
  void onWindowRestore() {
    _syncMaximized();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surfaceContainerHighest;

    return Container(
      height: AppTitleBar.height,
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => windowManager.startDragging(),
              onDoubleTap: _toggleMaximize,
              onSecondaryTap: () => windowManager.popUpWindowMenu(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Text(
                      'Better Bilibili',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _WindowButton(
            tooltip: '最小化',
            icon: Icons.remove_rounded,
            onPressed: () => windowManager.minimize(),
          ),
          _WindowButton(
            tooltip: _isMaximized ? '还原' : '最大化',
            icon: _isMaximized ? Icons.filter_none_rounded : Icons.crop_square_rounded,
            onPressed: _toggleMaximize,
          ),
          _WindowButton(
            tooltip: '关闭',
            icon: Icons.close_rounded,
            isClose: true,
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    await _syncMaximized();
  }

  Future<void> _syncMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    _setMaximized(isMaximized);
  }

  void _setMaximized(bool value) {
    if (!mounted || _isMaximized == value) {
      return;
    }
    setState(() => _isMaximized = value);
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = widget.isClose && _hovered ? Colors.white : colorScheme.onSurfaceVariant;
    final hoverColor = widget.isClose ? const Color(0xFFE81123) : colorScheme.onSurface.withAlpha(18);

    return Semantics(
      label: widget.tooltip,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: _hovered ? hoverColor : Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            child: SizedBox(
              width: 48,
              height: AppTitleBar.height,
              child: Icon(
                widget.icon,
                size: 18,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
