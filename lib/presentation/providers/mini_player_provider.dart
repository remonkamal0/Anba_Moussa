import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class MiniPlayerTrack {
  final String id;
  final String title;
  final String artist;
  final String coverImageUrl;

  const MiniPlayerTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverImageUrl,
  });
}

// ─── State ────────────────────────────────────────────────────────────────────

class MiniPlayerState {
  final MiniPlayerTrack? track;
  final bool isVisible;
  final bool isPlaying;

  const MiniPlayerState({
    this.track,
    this.isVisible = false,
    this.isPlaying = false,
  });

  MiniPlayerState copyWith({
    MiniPlayerTrack? track,
    bool? isVisible,
    bool? isPlaying,
  }) {
    return MiniPlayerState(
      track: track ?? this.track,
      isVisible: isVisible ?? this.isVisible,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class MiniPlayerNotifier extends StateNotifier<MiniPlayerState> {
  MiniPlayerNotifier() : super(const MiniPlayerState());

  /// Call when a track starts playing
  void play(MiniPlayerTrack track) {
    state = state.copyWith(
      track: track,
      isVisible: true,
      isPlaying: true,
    );
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void setPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  /// Hide the mini player (but keep the track alive in state)
  void hide() {
    state = state.copyWith(isVisible: false);
  }

  /// Show the mini player again with the current track
  void show() {
    if (state.track != null) {
      state = state.copyWith(isVisible: true);
    }
  }

  void dismiss() {
    state = const MiniPlayerState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final miniPlayerProvider =
    StateNotifierProvider<MiniPlayerNotifier, MiniPlayerState>(
  (ref) => MiniPlayerNotifier(),
);
