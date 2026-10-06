import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:flutter/material.dart';

class PanelLayer extends StatelessWidget {
  final PanelController controller;

  const PanelLayer({
    super.key,
    required this.controller,
  });

  bool get hasActivePanel => controller.activePanel != null;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !hasActivePanel,
              child: AnimatedOpacity(
                opacity: hasActivePanel ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: GestureDetector(
                  behavior: .opaque,
                  onTap: controller.popAll,
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
                width: controller.activePanel?.width,
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
                      child: hasActivePanel ? controller.activePanel!.build(context) : SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
