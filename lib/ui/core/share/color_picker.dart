import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

extension ColorPickerExtension on BuildContext {
  Future<Color?> showColorPicker({Color initialColor = Colors.blue, Color? resetColor}) {
    return showDialog<Color>(
      context: this,
      builder: (_) {
        return _ColorPickerDialog(
          initialColor: initialColor,
          resetColor: resetColor,
        );
      },
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({
    required this.initialColor,
    this.resetColor,
  });

  final Color initialColor;
  final Color? resetColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> with SingleTickerProviderStateMixin {
  late HSVColor _hsv;
  Color get _color => _hsv.toColor();

  late final TabController _tabController;

  final _hexController = TextEditingController();

  final _rController = TextEditingController();
  final _gController = TextEditingController();
  final _bController = TextEditingController();

  final _hslHController = TextEditingController();
  final _hslSController = TextEditingController();
  final _hslLController = TextEditingController();

  final _hsvHController = TextEditingController();
  final _hsvSController = TextEditingController();
  final _hsvVController = TextEditingController();

  final _colorAreaKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );

    _hsv = HSVColor.fromColor(widget.initialColor);
    _syncControllers();
  }

  @override
  void dispose() {
    _tabController.dispose();

    _hexController.dispose();

    _rController.dispose();
    _gController.dispose();
    _bController.dispose();

    _hslHController.dispose();
    _hslSController.dispose();
    _hslLController.dispose();

    _hsvHController.dispose();
    _hsvSController.dispose();
    _hsvVController.dispose();

    super.dispose();
  }

  void _setColor(Color color) {
    setState(() {
      _hsv = HSVColor.fromColor(color);

      _syncControllers();
    });
  }

  void _resetColor() {
    context.pop(widget.resetColor);
  }

  void _setHsv({
    double? hue,
    double? saturation,
    double? value,
    double? alpha,
  }) {
    setState(() {
      _hsv = HSVColor.fromAHSV(
        alpha ?? _hsv.alpha,
        hue ?? _hsv.hue,
        saturation ?? _hsv.saturation,
        value ?? _hsv.value,
      );

      _syncControllers();
    });
  }

  void _syncControllers() {
    final rgb = (
      r: (_color.r * 255).round(),
      g: (_color.g * 255).round(),
      b: (_color.b * 255).round(),
    );

    final hsl = HSLColor.fromColor(_color);
    final hsv = HSVColor.fromColor(_color);

    _hexController.text = _toHex(_color);

    _rController.text = rgb.r.toString();
    _gController.text = rgb.g.toString();
    _bController.text = rgb.b.toString();

    _hslHController.text = hsl.hue.round().toString();
    _hslSController.text = (hsl.saturation * 100).round().toString();
    _hslLController.text = (hsl.lightness * 100).round().toString();

    _hsvHController.text = hsv.hue.round().toString();
    _hsvSController.text = (hsv.saturation * 100).round().toString();
    _hsvVController.text = (hsv.value * 100).round().toString();
  }

  String _toHex(Color color) {
    final a = (color.a * 255).round();
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();

    if (a == 255) {
      return '#${_hex(r)}${_hex(g)}${_hex(b)}';
    }

    return '#${_hex(a)}${_hex(r)}${_hex(g)}${_hex(b)}';
  }

  String _hex(int value) {
    return value.toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  int? _parseInt(String text, int min, int max) {
    final value = int.tryParse(text.trim());

    if (value == null) {
      return null;
    }

    return value.clamp(min, max);
  }

  void _applyRgb() {
    final r = _parseInt(_rController.text, 0, 255);
    final g = _parseInt(_gController.text, 0, 255);
    final b = _parseInt(_bController.text, 0, 255);

    if (r == null || g == null || b == null) {
      return;
    }

    _setColor(
      Color.from(
        alpha: _color.a,
        red: r / 255,
        green: g / 255,
        blue: b / 255,
      ),
    );
  }

  void _applyHsl() {
    final h = double.tryParse(_hslHController.text);
    final s = double.tryParse(_hslSController.text);
    final l = double.tryParse(_hslLController.text);

    if (h == null || s == null || l == null) {
      return;
    }

    _setColor(
      HSLColor.fromAHSL(
        _color.a,
        h.clamp(0, 360),
        (s.clamp(0, 100)) / 100,
        (l.clamp(0, 100)) / 100,
      ).toColor(),
    );
  }

  void _applyHsv() {
    final h = double.tryParse(_hsvHController.text);
    final s = double.tryParse(_hsvSController.text);
    final v = double.tryParse(_hsvVController.text);

    if (h == null || s == null || v == null) {
      return;
    }

    _setColor(
      HSVColor.fromAHSV(
        _color.a,
        h.clamp(0, 360),
        (s.clamp(0, 100)) / 100,
        (v.clamp(0, 100)) / 100,
      ).toColor(),
    );
  }

  void _applyHex() {
    var value = _hexController.text.trim();

    if (value.startsWith('#')) {
      value = value.substring(1);
    }

    if (value.length == 6) {
      value = 'FF$value';
    }

    if (value.length != 8) {
      return;
    }

    final number = int.tryParse(value, radix: 16);

    if (number == null) {
      return;
    }

    _setColor(Color(number));
  }

  void _updateColorArea(Offset position) {
    final renderObject = _colorAreaKey.currentContext?.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final size = renderObject.size;

    final saturation = (position.dx / size.width).clamp(0.0, 1.0);

    final value = (1 - position.dy / size.height).clamp(0.0, 1.0);

    _setHsv(
      saturation: saturation,
      value: value,
    );
  }

  void _applyCurrentInput() {
    switch (_tabController.index) {
      case 0:
        _applyHex();
      case 1:
        _applyRgb();
      case 2:
        _applyHsl();
      case 3:
        _applyHsv();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择颜色'),
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 560,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorArea(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Column(
                  children: [
                    _buildHueSlider(),
                    _buildAlphaSlider(),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _buildTabBar(),
              _buildFormatInputs(),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            if (widget.resetColor != null)
              TextButton(
                onPressed: _resetColor,
                child: const Text('重置'),
              ),

            const Spacer(),

            TextButton(
              onPressed: () => context.pop(),
              child: const Text('取消'),
            ),

            const SizedBox(width: 8),

            FilledButton(
              onPressed: () {
                _applyCurrentInput();
                context.pop(_color);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorArea() {
    return AspectRatio(
      aspectRatio: 1.6,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (details) {
          _updateColorArea(details.localPosition);
        },
        onPanUpdate: (details) {
          _updateColorArea(details.localPosition);
        },
        child: Stack(
          key: _colorAreaKey,
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _ColorAreaPainter(
                hue: _hsv.hue,
              ),
            ),
            Align(
              alignment: FractionalOffset(
                _hsv.saturation,
                1 - _hsv.value,
              ),
              child: IgnorePointer(
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHueSlider() {
    return _ColorSlider(
      value: _hsv.hue,
      min: 0,
      max: 360,
      label: '色相',
      valueText: '${_hsv.hue.round()}°',
      gradient: const LinearGradient(
        colors: [
          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          Colors.purple,
          Colors.red,
        ],
      ),
      onChanged: (value) {
        _setHsv(hue: value);
      },
    );
  }

  Widget _buildAlphaSlider() {
    return _ColorSlider(
      value: _color.a,
      min: 0,
      max: 1,
      label: '透明度',
      valueText: '${(_color.a * 100).round()}%',
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          _color.withValues(alpha: 1),
        ],
      ),
      onChanged: (value) {
        _setHsv(alpha: value);
      },
    );
  }

  Widget _buildSliderInput({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required TextEditingController controller,
    int divisions = 255,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value.clamp(min, max),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onSubmitted: (_) => _applyCurrentInput(),
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatInputs() {
    return ListenableBuilder(
      listenable: _tabController,
      builder: (context, child) {
        switch (_tabController.index) {
          case 0:
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _hexController,
                keyboardType: TextInputType.text,
                onSubmitted: (_) => _applyHex(),
                decoration: const InputDecoration(
                  labelText: 'HEX',
                  hintText: '#RRGGBB / #AARRGGBB',
                  border: OutlineInputBorder(),
                ),
              ),
            );

          case 1:
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                children: [
                  _buildSliderInput(
                    label: 'R',
                    value: _color.r * 255,
                    min: 0,
                    max: 255,
                    controller: _rController,
                    onChanged: (value) {
                      final color = Color.from(
                        alpha: _color.a,
                        red: value / 255,
                        green: _color.g,
                        blue: _color.b,
                      );

                      _setColor(color);
                    },
                  ),
                  _buildSliderInput(
                    label: 'G',
                    value: _color.g * 255,
                    min: 0,
                    max: 255,
                    controller: _gController,
                    onChanged: (value) {
                      final color = Color.from(
                        alpha: _color.a,
                        red: _color.r,
                        green: value / 255,
                        blue: _color.b,
                      );

                      _setColor(color);
                    },
                  ),
                  _buildSliderInput(
                    label: 'B',
                    value: _color.b * 255,
                    min: 0,
                    max: 255,
                    controller: _bController,
                    onChanged: (value) {
                      final color = Color.from(
                        alpha: _color.a,
                        red: _color.r,
                        green: _color.g,
                        blue: value / 255,
                      );

                      _setColor(color);
                    },
                  ),
                ],
              ),
            );

          case 2:
            final hsl = HSLColor.fromColor(_color);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                children: [
                  _buildSliderInput(
                    label: 'H',
                    value: hsl.hue,
                    min: 0,
                    max: 360,
                    controller: _hslHController,
                    divisions: 360,
                    onChanged: (value) {
                      _setColor(
                        HSLColor.fromAHSL(
                          _color.a,
                          value,
                          hsl.saturation,
                          hsl.lightness,
                        ).toColor(),
                      );
                    },
                  ),
                  _buildSliderInput(
                    label: 'S',
                    value: hsl.saturation * 100,
                    min: 0,
                    max: 100,
                    controller: _hslSController,
                    divisions: 100,
                    onChanged: (value) {
                      _setColor(
                        HSLColor.fromAHSL(
                          _color.a,
                          hsl.hue,
                          value / 100,
                          hsl.lightness,
                        ).toColor(),
                      );
                    },
                  ),
                  _buildSliderInput(
                    label: 'L',
                    value: hsl.lightness * 100,
                    min: 0,
                    max: 100,
                    controller: _hslLController,
                    divisions: 100,
                    onChanged: (value) {
                      _setColor(
                        HSLColor.fromAHSL(
                          _color.a,
                          hsl.hue,
                          hsl.saturation,
                          value / 100,
                        ).toColor(),
                      );
                    },
                  ),
                ],
              ),
            );

          case 3:
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                children: [
                  _buildSliderInput(
                    label: 'H',
                    value: _hsv.hue,
                    min: 0,
                    max: 360,
                    controller: _hsvHController,
                    divisions: 360,
                    onChanged: (value) {
                      _setHsv(hue: value);
                    },
                  ),
                  _buildSliderInput(
                    label: 'S',
                    value: _hsv.saturation * 100,
                    min: 0,
                    max: 100,
                    controller: _hsvSController,
                    divisions: 100,
                    onChanged: (value) {
                      _setHsv(
                        saturation: value / 100,
                      );
                    },
                  ),
                  _buildSliderInput(
                    label: 'V',
                    value: _hsv.value * 100,
                    min: 0,
                    max: 100,
                    controller: _hsvVController,
                    divisions: 100,
                    onChanged: (value) {
                      _setHsv(
                        value: value / 100,
                      );
                    },
                  ),
                ],
              ),
            );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'HEX'),
        Tab(text: 'RGB'),
        Tab(text: 'HSL'),
        Tab(text: 'HSV'),
      ],
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.valueText,
    required this.gradient,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final String label;
  final String valueText;
  final Gradient gradient;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(label),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              Slider(
                min: min,
                max: max,
                value: value.clamp(min, max),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            valueText,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _ColorAreaPainter extends CustomPainter {
  const _ColorAreaPainter({
    required this.hue,
  });

  final double hue;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final baseColor = HSVColor.fromAHSV(
      1,
      hue,
      1,
      1,
    ).toColor();

    canvas.drawRect(
      rect,
      Paint()..color = baseColor,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Colors.white,
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ColorAreaPainter oldDelegate) {
    return oldDelegate.hue != hue;
  }
}
