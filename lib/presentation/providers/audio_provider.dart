import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/services/download_service.dart';
import '../../core/di/service_locator.dart';
import 'mini_player_provider.dart';

// ─── State ─────────────────────────────────────────────────────────────────────

class AudioState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isShuffleModeEnabled;
  final LoopMode loopMode;
  final String? currentUrl;
  final MiniPlayerTrack? currentTrack;

  const AudioState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffleModeEnabled = false,
    this.loopMode = LoopMode.off,
    this.currentUrl,
    this.currentTrack,
  });

  AudioState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isShuffleModeEnabled,
    LoopMode? loopMode,
    String? currentUrl,
    MiniPlayerTrack? currentTrack,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffleModeEnabled: isShuffleModeEnabled ?? this.isShuffleModeEnabled,
      loopMode: loopMode ?? this.loopMode,
      currentUrl: currentUrl ?? this.currentUrl,
      currentTrack: currentTrack ?? this.currentTrack,
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
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<bool>? _shuffleSub;
  StreamSubscription<LoopMode>? _loopSub;

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
      _ref.read(miniPlayerProvider.notifier).setPlaying(playing);
    });
    _shuffleSub = player.shuffleModeEnabledStream.listen((enabled) {
      state = state.copyWith(isShuffleModeEnabled: enabled);
    });
    _loopSub = player.loopModeStream.listen((loopMode) {
      state = state.copyWith(loopMode: loopMode);
    });
    _indexSub = player.currentIndexStream.listen((index) {
      if (index != null) {
        MiniPlayerTrack? currentTrack;
        
        final source = player.audioSource;
        if (source is ConcatenatingAudioSource) {
          if (index >= 0 && index < source.children.length) {
            final audioSource = source.children[index];
            final dynamic tag = (audioSource as dynamic).tag;
            if (tag is MiniPlayerTrack) {
              currentTrack = tag;
            }
          }
        } else if (source != null) {
          final dynamic tag = (source as dynamic).tag;
          if (tag is MiniPlayerTrack) {
            currentTrack = tag;
          }
        }

        if (currentTrack != null) {
          state = state.copyWith(currentTrack: currentTrack);
          _ref.read(miniPlayerProvider.notifier).play(currentTrack);
        }
      }
    });
  }

  Future<void> loadPlaylist(List<dynamic> tracks, int initialIndex) async {
    try {
      final miniTracks = tracks.map((t) => MiniPlayerTrack(
        id: t.id,
        titleAr: t.titleAr,
        titleEn: t.titleEn,
        speakerAr: t.speakerAr ?? '',
        speakerEn: t.speakerEn ?? '',
        coverImageUrl: t.imageUrl ?? '',
        audioUrl: t.audioUrl,
      )).toList();

      final audioSource = ConcatenatingAudioSource(
        children: tracks.asMap().entries.map((entry) {
          final idx = entry.key;
          final t = entry.value;
          final localPath = DownloadService.instance.getLocalPath(t.id);
          
          if (localPath != null) {
            return AudioSource.file(
              localPath,
              tag: miniTracks[idx],
            );
          }
          
          return AudioSource.uri(
            Uri.parse(t.audioUrl),
            tag: miniTracks[idx],
          );
        }).toList(),
      );

      await player.setAudioSource(audioSource, initialIndex: initialIndex);
      
      final currentMiniTrack = miniTracks[initialIndex];
      state = state.copyWith(
        currentTrack: currentMiniTrack,
        currentUrl: tracks[initialIndex].audioUrl,
      );
      _ref.read(miniPlayerProvider.notifier).play(currentMiniTrack);
      
      await player.play();
    } catch (e) {
      print('Error loading playlist: $e');
    }
  }

  Future<void> loadAndPlay(String url, MiniPlayerTrack track) async {
    try {
      state = state.copyWith(currentUrl: url, currentTrack: track);
      
      final localPath = DownloadService.instance.getLocalPath(track.id);
      if (localPath != null) {
        await player.setAudioSource(AudioSource.file(localPath, tag: track));
      } else {
        await player.setAudioSource(AudioSource.uri(Uri.parse(url), tag: track));
      }
      
      _ref.read(miniPlayerProvider.notifier).play(track);
      await player.play();
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  Future<void> loadAndPlayTrack(dynamic trackEntity) async {
    // We use dynamic to avoid circular imports if needed, but here Track is accessible
    // Mapping Track (domain) to MiniPlayerTrack (presentation/provider)
    final miniTrack = MiniPlayerTrack(
      id: trackEntity.id,
      titleAr: trackEntity.titleAr,
      titleEn: trackEntity.titleEn,
      speakerAr: trackEntity.speakerAr ?? '',
      speakerEn: trackEntity.speakerEn ?? '',
      coverImageUrl: trackEntity.imageUrl ?? '',
      audioUrl: trackEntity.audioUrl,
    );

    await loadAndPlay(trackEntity.audioUrl, miniTrack);
  }

  void skipForward() {
    if (player.hasNext) {
      player.seekToNext();
    } else {
      // If no next track, maybe just seek 10s? 
      // User expected "Next" to work as next track though.
      final nextPos = player.position + const Duration(seconds: 10);
      if (nextPos < (player.duration ?? Duration.zero)) {
        player.seek(nextPos);
      }
    }
  }

  void skipBackward() {
    if (player.hasPrevious) {
      player.seekToPrevious();
    } else {
      final prevPos = player.position - const Duration(seconds: 10);
      player.seek(prevPos < Duration.zero ? Duration.zero : prevPos);
    }
  }

  void togglePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void stop() async {
    await player.stop();
    _ref.read(miniPlayerProvider.notifier).dismiss();
    state = state.copyWith(
      currentUrl: null,
      currentTrack: null,
      isPlaying: false,
      position: Duration.zero,
    );
  }

  void seek(Duration position) {
    player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  void toggleShuffle() {
    final newValue = !player.shuffleModeEnabled;
    player.setShuffleModeEnabled(newValue);
  }

  void toggleRepeat() {
    final nextMode = switch (player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    player.setLoopMode(nextMode);
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playingSub?.cancel();
    _indexSub?.cancel();
    _shuffleSub?.cancel();
    _loopSub?.cancel();
    player.dispose();
    super.dispose();
  }
}

// ─── Provider ──────────────────────────────────────────────────────────────────

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>(
  (ref) => AudioNotifier(ref),
);
