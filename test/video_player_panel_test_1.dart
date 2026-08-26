import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue, useMaterial3: true),
      home: const VideoPlayerPanelTest1(),
    ),
  );
}

class VideoPlayerPanelTest1 extends StatefulWidget {
  const VideoPlayerPanelTest1({super.key});

  @override
  State<VideoPlayerPanelTest1> createState() => _VideoPlayerPanelTest1State();
}

class _VideoPlayerPanelTest1State extends State<VideoPlayerPanelTest1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VideoPlayerPanelTest1')),
      body: const Center(
        child: SizedBox(
          width: 1920 / 2,
          height: 1080 / 2,
          child: InnerWidget(),
        ),
      ),
    );
  }
}

enum PlayerPanel {
  none,
  speed,
  quality,
  settings,
}

enum EncodingSlot {
  preferred,
  fallback,
}

class InnerWidget extends StatefulWidget {
  const InnerWidget({super.key});

  @override
  State<InnerWidget> createState() => _InnerWidgetState();
}

class _InnerWidgetState extends State<InnerWidget> {
  PlayerPanel _activePanel = PlayerPanel.none;
  double _speed = 1.0;
  String _quality = '1080P';
  String _preferredEncoding = 'H.265';
  String _fallbackEncoding = 'H.264';
  bool _autoPlay = true;
  bool _smtcEnabled = true;

  bool get _isPanelOpen => _activePanel != PlayerPanel.none;

  void _openPanel(PlayerPanel panel) {
    setState(() {
      _activePanel = panel;
    });
  }

  void _closePanel() {
    setState(() {
      _activePanel = PlayerPanel.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.black,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: Color(0xFF1F2937)),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 86,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_isPanelOpen,
                child: AnimatedOpacity(
                  opacity: _isPanelOpen ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _closePanel,
                    child: Container(color: Colors.black38),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _PlayerControls(
                speed: _speed,
                quality: _quality,
                onSpeedPressed: () => _openPanel(PlayerPanel.speed),
                onQualityPressed: () => _openPanel(PlayerPanel.quality),
                onSettingsPressed: () => _openPanel(PlayerPanel.settings),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedSlide(
                offset: _isPanelOpen ? Offset.zero : const Offset(1, 0),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: 300,
                  height: double.infinity,
                  child: _PlayerSidePanel(
                    activePanel: _activePanel,
                    speed: _speed,
                    quality: _quality,
                    preferredEncoding: _preferredEncoding,
                    fallbackEncoding: _fallbackEncoding,
                    autoPlay: _autoPlay,
                    smtcEnabled: _smtcEnabled,
                    onClose: _closePanel,
                    onSpeedSelected: (speed) {
                      setState(() {
                        _speed = speed;
                      });
                    },
                    onQualitySelected: (quality) {
                      setState(() {
                        _quality = quality;
                      });
                    },
                    onAutoPlayChanged: (value) {
                      setState(() {
                        _autoPlay = value;
                      });
                    },
                    onSmtcChanged: (value) {
                      setState(() {
                        _smtcEnabled = value;
                      });
                    },
                    onEncodingSelected: (slot, encoding) {
                      setState(() {
                        switch (slot) {
                          case EncodingSlot.preferred:
                            _preferredEncoding = encoding;
                          case EncodingSlot.fallback:
                            _fallbackEncoding = encoding;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.speed,
    required this.quality,
    required this.onSpeedPressed,
    required this.onQualityPressed,
    required this.onSettingsPressed,
  });

  final double speed;
  final String quality;
  final VoidCallback onSpeedPressed;
  final VoidCallback onQualityPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 36, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                value: 0.42,
                minHeight: 4,
                color: Color(0xFF00A1D6),
                backgroundColor: Colors.white24,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  color: Colors.white,
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  tooltip: '播放',
                ),
                const Text(
                  '08:24 / 20:00',
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                _ControlButton(label: '${speed}x', onPressed: onSpeedPressed),
                const SizedBox(width: 8),
                _ControlButton(label: quality, onPressed: onQualityPressed),
                const SizedBox(width: 8),
                IconButton(
                  color: Colors.white,
                  onPressed: onSettingsPressed,
                  icon: const Icon(Icons.settings),
                  tooltip: '设置',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

class _PlayerSidePanel extends StatelessWidget {
  const _PlayerSidePanel({
    required this.activePanel,
    required this.speed,
    required this.quality,
    required this.preferredEncoding,
    required this.fallbackEncoding,
    required this.autoPlay,
    required this.smtcEnabled,
    required this.onClose,
    required this.onSpeedSelected,
    required this.onQualitySelected,
    required this.onAutoPlayChanged,
    required this.onSmtcChanged,
    required this.onEncodingSelected,
  });

  final PlayerPanel activePanel;
  final double speed;
  final String quality;
  final String preferredEncoding;
  final String fallbackEncoding;
  final bool autoPlay;
  final bool smtcEnabled;
  final VoidCallback onClose;
  final ValueChanged<double> onSpeedSelected;
  final ValueChanged<String> onQualitySelected;
  final ValueChanged<bool> onAutoPlayChanged;
  final ValueChanged<bool> onSmtcChanged;
  final void Function(EncodingSlot slot, String encoding) onEncodingSelected;

  @override
  Widget build(BuildContext context) {
    if (activePanel == PlayerPanel.settings) {
      return _SettingsPanelFlow(
        preferredEncoding: preferredEncoding,
        fallbackEncoding: fallbackEncoding,
        autoPlay: autoPlay,
        smtcEnabled: smtcEnabled,
        onClose: onClose,
        onAutoPlayChanged: onAutoPlayChanged,
        onSmtcChanged: onSmtcChanged,
        onEncodingSelected: onEncodingSelected,
      );
    }

    return Material(
      elevation: 12,
      color: const Color(0xFF111827),
      child: SafeArea(
        child: Column(
          children: [
            _PanelHeader(title: _panelTitle, onClose: onClose),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: switch (activePanel) {
                  PlayerPanel.speed => _OptionList<double>(
                    key: const ValueKey(PlayerPanel.speed),
                    values: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
                    selectedValue: speed,
                    labelBuilder: (value) => '${value}x',
                    onSelected: onSpeedSelected,
                  ),
                  PlayerPanel.quality => _OptionList<String>(
                    key: const ValueKey(PlayerPanel.quality),
                    values: const ['360P', '480P', '720P', '1080P', '4K'],
                    selectedValue: quality,
                    labelBuilder: (value) => value,
                    onSelected: onQualitySelected,
                  ),
                  PlayerPanel.none => const SizedBox.shrink(),
                  PlayerPanel.settings => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _panelTitle {
    return switch (activePanel) {
      PlayerPanel.speed => '播放速度',
      PlayerPanel.quality => '清晰度',
      PlayerPanel.settings => '播放设置',
      PlayerPanel.none => '',
    };
  }
}

class _SettingsPanelFlow extends StatefulWidget {
  const _SettingsPanelFlow({
    required this.preferredEncoding,
    required this.fallbackEncoding,
    required this.autoPlay,
    required this.smtcEnabled,
    required this.onClose,
    required this.onAutoPlayChanged,
    required this.onSmtcChanged,
    required this.onEncodingSelected,
  });

  final String preferredEncoding;
  final String fallbackEncoding;
  final bool autoPlay;
  final bool smtcEnabled;
  final VoidCallback onClose;
  final ValueChanged<bool> onAutoPlayChanged;
  final ValueChanged<bool> onSmtcChanged;
  final void Function(EncodingSlot slot, String encoding) onEncodingSelected;

  @override
  State<_SettingsPanelFlow> createState() => _SettingsPanelFlowState();
}

class _SettingsPanelFlowState extends State<_SettingsPanelFlow> {
  static const String _settingsRoute = '/';
  static const String _encodingRoute = '/encoding';

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _openEncodingPanel(EncodingSlot slot) {
    _navigatorKey.currentState?.pushNamed(_encodingRoute, arguments: slot);
  }

  void _selectEncoding(EncodingSlot slot, String encoding) {
    widget.onEncodingSelected(slot, encoding);
    _navigatorKey.currentState?.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: const Color(0xFF111827),
      child: SafeArea(
        child: Navigator(
          key: _navigatorKey,
          initialRoute: _settingsRoute,
          onGenerateRoute: (settings) {
            final Widget child;

            switch (settings.name) {
              case _settingsRoute:
                child = _SettingsHomePanel(
                  preferredEncoding: widget.preferredEncoding,
                  fallbackEncoding: widget.fallbackEncoding,
                  autoPlay: widget.autoPlay,
                  smtcEnabled: widget.smtcEnabled,
                  onClose: widget.onClose,
                  onAutoPlayChanged: widget.onAutoPlayChanged,
                  onSmtcChanged: widget.onSmtcChanged,
                  onPreferredEncodingPressed: () {
                    _openEncodingPanel(EncodingSlot.preferred);
                  },
                  onFallbackEncodingPressed: () {
                    _openEncodingPanel(EncodingSlot.fallback);
                  },
                );
              case _encodingRoute:
                final slot = settings.arguments! as EncodingSlot;
                child = _EncodingSelectionPanel(
                  slot: slot,
                  selectedEncoding: switch (slot) {
                    EncodingSlot.preferred => widget.preferredEncoding,
                    EncodingSlot.fallback => widget.fallbackEncoding,
                  },
                  onBack: () => _navigatorKey.currentState?.pop(),
                  onClose: widget.onClose,
                  onSelected: (encoding) {
                    _selectEncoding(slot, encoding);
                  },
                );
              default:
                child = const SizedBox.shrink();
            }

            return PageRouteBuilder<void>(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => child,
              transitionsBuilder:
                  (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    final offsetAnimation =
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          ),
                        );

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
            );
          },
        ),
      ),
    );
  }
}

class _SettingsHomePanel extends StatelessWidget {
  const _SettingsHomePanel({
    required this.preferredEncoding,
    required this.fallbackEncoding,
    required this.autoPlay,
    required this.smtcEnabled,
    required this.onClose,
    required this.onAutoPlayChanged,
    required this.onSmtcChanged,
    required this.onPreferredEncodingPressed,
    required this.onFallbackEncodingPressed,
  });

  final String preferredEncoding;
  final String fallbackEncoding;
  final bool autoPlay;
  final bool smtcEnabled;
  final VoidCallback onClose;
  final ValueChanged<bool> onAutoPlayChanged;
  final ValueChanged<bool> onSmtcChanged;
  final VoidCallback onPreferredEncodingPressed;
  final VoidCallback onFallbackEncodingPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PanelHeader(title: '播放设置', onClose: onClose),
        const Divider(height: 1, color: Colors.white12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              SwitchListTile(
                value: autoPlay,
                onChanged: onAutoPlayChanged,
                activeColor: const Color(0xFF00A1D6),
                dense: true,
                title: const Text('自动播放', style: TextStyle(color: Colors.white)),
              ),
              _SettingsNavigationTile(
                title: '首选编码方式',
                value: preferredEncoding,
                onTap: onPreferredEncodingPressed,
              ),
              _SettingsNavigationTile(
                title: '备选编码方式',
                value: fallbackEncoding,
                onTap: onFallbackEncodingPressed,
              ),
              SwitchListTile(
                value: smtcEnabled,
                onChanged: onSmtcChanged,
                activeColor: const Color(0xFF00A1D6),
                dense: true,
                title: const Text('SMTC 支持', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsNavigationTile extends StatelessWidget {
  const _SettingsNavigationTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white70),
    );
  }
}

class _EncodingSelectionPanel extends StatelessWidget {
  const _EncodingSelectionPanel({
    required this.slot,
    required this.selectedEncoding,
    required this.onBack,
    required this.onClose,
    required this.onSelected,
  });

  final EncodingSlot slot;
  final String selectedEncoding;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const encodings = ['AVC', 'H.264', 'H.265', 'AV1', 'H.266'];

    return Material(
      color: Colors.black,
      child: Column(
        children: [
          _PanelHeader(
            title: switch (slot) {
              EncodingSlot.preferred => '首选编码方式',
              EncodingSlot.fallback => '备选编码方式',
            },
            leading: IconButton(
              color: Colors.white70,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              tooltip: '返回',
            ),
            onClose: onClose,
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: encodings.length,
              separatorBuilder: (context, index) {
                return const Divider(height: 1, color: Colors.white10);
              },
              itemBuilder: (context, index) {
                final encoding = encodings[index];
                final selected = encoding == selectedEncoding;

                return ListTile(
                  onTap: () => onSelected(encoding),
                  dense: true,
                  title: Text(
                    encoding,
                    style: TextStyle(
                      color: selected ? const Color(0xFF00A1D6) : Colors.white,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: selected ? const Icon(Icons.check, color: Color(0xFF00A1D6)) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    required this.onClose,
    this.leading,
  });

  final String title;
  final VoidCallback onClose;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: leading == null ? 8 : 0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            color: Colors.white70,
            onPressed: onClose,
            icon: const Icon(Icons.close),
            tooltip: '关闭',
          ),
        ],
      ),
    );
  }
}

class _OptionList<T> extends StatelessWidget {
  const _OptionList({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> values;
  final T selectedValue;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: values.length,
      separatorBuilder: (context, index) {
        return const Divider(height: 1, color: Colors.white10);
      },
      itemBuilder: (context, index) {
        final value = values[index];
        final selected = value == selectedValue;

        return ListTile(
          onTap: () => onSelected(value),
          dense: true,
          title: Text(
            labelBuilder(value),
            style: TextStyle(
              color: selected ? const Color(0xFF00A1D6) : Colors.white,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          trailing: selected ? const Icon(Icons.check, color: Color(0xFF00A1D6)) : null,
        );
      },
    );
  }
}
