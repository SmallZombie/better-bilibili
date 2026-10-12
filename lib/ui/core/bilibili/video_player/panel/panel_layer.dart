import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:material_ui/material_ui.dart';

class PanelLayer extends StatefulWidget {
  final PanelController controller;

  const PanelLayer({super.key, required this.controller});

  @override
  State<PanelLayer> createState() => _PanelLayerState();
}

class _PanelLayerState extends State<PanelLayer> {
  PanelController get controller => widget.controller;
  bool get hasActivePanel => widget.controller.activePanel != null;

  @override
  void initState() {
    super.initState();

    controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);

    super.dispose();
  }

  double _prewPanelWidth = 0.0;

  void _onChanged() {
    if (hasActivePanel) {
      _prewPanelWidth = controller.activePanel!.width;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !hasActivePanel,
            child: AnimatedOpacity(
              opacity: hasActivePanel ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: GestureDetector(
                behavior: .opaque,
                onTap: widget.controller.popAll,
                child: Container(color: Colors.black38),
              ),
            ),
          ),
        ),
        Align(
          alignment: .centerRight,
          child: AnimatedSlide(
            offset: hasActivePanel ? .zero : const Offset(1, 0),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: widget.controller.activePanel?.width ?? _prewPanelWidth,
              height: .infinity,
              child: Material(
                elevation: 12,
                color: Colors.black.withAlpha(150),
                borderRadius: .only(
                  topLeft: .circular(24),
                  bottomLeft: .circular(24),
                ),
                clipBehavior: .antiAlias,
                child: SafeArea(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: hasActivePanel ? widget.controller.activePanel!.build(context) : SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
