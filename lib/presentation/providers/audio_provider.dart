import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'mini_player_provider.dart';

// ─── State ─────────────────────────────────────────────────────────────────────

class AudioState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? currentUrl;

  const AudioState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentUrl,
  });

  AudioState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? currentUrl,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentUrl: currentUrl ?? this.currentUrl,
    );
  }
}

// ─── Notifier ──────────────────────────────────────────────────────────────────

class AudioNotifier extends StateNotifier<AudioState> {
  final Ref _ref;
  late final AudioPlayer player;

  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;

  AudioNotifier(this._ref) : super(const AudioState()) {
    player = AudioPlayer();
    _setupListeners();
  }

  void _setupListeners() {
    _durationSub = player.durationStream.listen((d) {
      if (d != null) state = state.copyWith(duration: d);
    });
    _positionSub = player.positionStream.listen((p) {
      state = state.copyWith(position: p);
    });
    _playingSub = player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
      // Keep mini player in sync
      final miniNotifier = _ref.read(miniPlayerProvider.notifier);
      if (playing) {
        miniNotifier.setPlaying(true);
      } else {
        miniNotifier.setPlaying(false);
      }
    });
  }

  Future<void> loadAndPlay(String url, MiniPlayerTrack track) async {
    try {
      state = state.copyWith(currentUrl: url);
      await player.setUrl(url);
      // Register track in mini player (hidden while on PlayerScreen)
      _ref.read(miniPlayerProvider.notifier).play(track);
      await player.play();
    } catch (_) {}
  }

  void togglePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void seek(Duration position) {
    player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playingSub?.cancel();
    player.dispose();
    super.dispose();
  }
}

// ─── Provider ──────────────────────────────────────────────────────────────────

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>(
  (ref) => AudioNotifier(ref),
);
