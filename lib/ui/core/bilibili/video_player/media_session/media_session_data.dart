import 'dart:async';

class MediaSessionData {
  MediaInfoState state;
  late final stream = MediaSessionDataStream();

  MediaSessionData({String? title, String? artist}) : state = MediaInfoState(title: title ?? '', artist: artist);

  void dispose() {
    stream.dispose();
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
    stream._titleControler.add(title);
  }

  void setArtist(String artist) {
    state = state.copyWith(artist: artist);
    stream._artistController.add(artist);
  }

  void setPrivacyMode(bool privacyMode) {
    state = state.copyWith(privacyMode: privacyMode);
    stream._privacyModeController.add(privacyMode);
  }
}

class MediaInfoState {
  final String title;
  final String? artist;
  final bool privacyMode;

  const MediaInfoState({
    this.title = '',
    this.artist,
    this.privacyMode = false,
  });

  MediaInfoState copyWith({
    String? title,
    String? artist,
    bool? privacyMode,
  }) {
    return MediaInfoState(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      privacyMode: privacyMode ?? this.privacyMode,
    );
  }
}

class MediaSessionDataStream {
  late final StreamController<String> _titleControler = StreamController.broadcast();
  late final StreamController<String> _artistController = StreamController.broadcast();
  late final StreamController<bool> _privacyModeController = StreamController.broadcast();

  late final Stream<String> title = _titleControler.stream;
  late final Stream<String?> artist = _artistController.stream;
  late final Stream<bool> privacyMode = _privacyModeController.stream;

  void dispose() {
    _titleControler.close();
    _artistController.close();
    _privacyModeController.close();
  }
}
