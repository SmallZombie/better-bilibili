import 'package:better_bilibili/ui/core/bilibili/video_player/panel_player_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggle panel opens and closes the active panel', () {
    final state = PanelPlayerState();

    state.togglePanel('quality');
    expect(state.activePanel, 'quality');

    state.togglePanel('quality');
    expect(state.activePanel, isNull);
  });

  test('openPanel updates hasActivePanel', () {
    final state = PanelPlayerState();

    state.openPanel('settings');
    expect(state.hasActivePanel, isTrue);
    expect(state.activePanel, 'settings');
  });
}
