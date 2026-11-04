import 'package:better_bilibili/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nativeapi_flutter/nativeapi_flutter.dart';

class AppTitleBar extends StatefulWidget {
  final AppConfig config;

  const AppTitleBar({required this.config, super.key});

  static const height = 36.0;

  @override
  State<AppTitleBar> createState() => _AppTitleBarState();
}

class _AppTitleBarState extends State<AppTitleBar> {
  Window? _window;
  int? _windowListenerId;

  var _isMaximized = false;

  @override
  void initState() {
    super.initState();

    _window = WindowManager.instance.getCurrent();

    final window = _window;
    if (window == null) return;

    _windowListenerId = window.addListener(_onWindowEvent);
    _syncMaximized();
  }

  @override
  void dispose() {
    if (_windowListenerId != null) {
      _window?.removeListener(_windowListenerId!);
    }

    super.dispose();
  }

  void _onWindowEvent(WindowEvent event) {
    if (event is WindowMaximizedEvent) {
      _setMaximized(true);
    } else if (event is WindowRestoredEvent) {
      _syncMaximized();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = colorScheme.surfaceContainerHighest;

    return Container(
      height: AppTitleBar.height,
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            child: DragToMoveArea(
              window: _window,
              child: Padding(
                padding: const .only(left: 16),
                child: Row(
                  spacing: 6.0,
                  children: [
                    Text(
                      widget.config.appName,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (kDebugMode)
                      Text(
                        '(Debug mode)',
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.outline,
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
            onPressed: () => _window?.minimize(),
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
            onPressed: () => _window?.close(),
          ),
        ],
      ),
    );
  }

  void _toggleMaximize() {
    final window = _window;
    if (window == null) return;

    if (window.isMaximized) {
      window.unmaximize();
    } else {
      window.maximize();
    }

    _syncMaximized();
  }

  void _syncMaximized() {
    final isMaximized = _window?.isMaximized ?? false;
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
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

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
