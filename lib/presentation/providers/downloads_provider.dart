import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../../core/services/download_service.dart';
import '../../core/di/service_locator.dart';

class DownloadsState {
  final List<Track> downloadedTracks;
  final Map<String, double> downloadProgress; // trackId -> 0.0 to 1.0
  final bool isLoading;

  DownloadsState({
    this.downloadedTracks = const [],
    this.downloadProgress = const {},
    this.isLoading = false,
  });

  DownloadsState copyWith({
    List<Track>? downloadedTracks,
    Map<String, double>? downloadProgress,
    bool? isLoading,
  }) {
    return DownloadsState(
      downloadedTracks: downloadedTracks ?? this.downloadedTracks,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DownloadsNotifier extends StateNotifier<DownloadsState> {
  DownloadsNotifier() : super(DownloadsState()) {
    _init();
  }

  void _init() {
    final ids = DownloadService.instance.getAllDownloadedIds();
    final tracks = ids
        .map((id) => DownloadService.instance.getTrack(id))
        .whereType<Track>()
        .toList();
    state = state.copyWith(downloadedTracks: tracks);
  }

  Future<void> downloadTrack(Track track) async {
    if (DownloadService.instance.isDownloaded(track.id)) return;

    // Initialize progress
    state = state.copyWith(
      downloadProgress: {...state.downloadProgress, track.id: 0.0},
    );

    try {
      await DownloadService.instance.downloadTrack(track, (progress) {
        state = state.copyWith(
          downloadProgress: {...state.downloadProgress, track.id: progress},
        );
      });

      // Sync with Supabase
      try {
        await sl.trackRepository.downloadTrack(track.id);
      } catch (e) {
        // If sync fails, we still have it locally, but we might want to retry later
        // For now just log or ignore
      }

      state = state.copyWith(
        downloadedTracks: [...state.downloadedTracks, track],
        downloadProgress: Map.from(state.downloadProgress)..remove(track.id),
      );
    } catch (e) {
      state = state.copyWith(
        downloadProgress: Map.from(state.downloadProgress)..remove(track.id),
      );
      rethrow;
    }
  }

  Future<void> removeDownload(String trackId) async {
    await DownloadService.instance.deleteDownload(trackId);

    // Sync with Supabase (delete record)
    try {
      await sl.trackRepository.removeFromDownloads(trackId);
    } catch (e) {
      // Ignore sync failure on delete
    }

    state = state.copyWith(
      downloadedTracks: state.downloadedTracks
          .where((t) => t.id != trackId)
          .toList(),
    );
  }

  bool isDownloaded(String trackId) =>
      state.downloadedTracks.any((t) => t.id == trackId);
  double? getProgress(String trackId) => state.downloadProgress[trackId];
}

final downloadsProvider =
    StateNotifierProvider<DownloadsNotifier, DownloadsState>((ref) {
      return DownloadsNotifier();
    });
