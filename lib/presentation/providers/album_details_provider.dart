import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/entities/tag.dart';
import '../../../core/di/service_locator.dart';

class AlbumDetailsState {
  final List<Track> allTracks;
  final List<Track> filteredTracks;
  final List<Tag> tags;
  final String? selectedTagId;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> downloadedTrackIds;

  AlbumDetailsState({
    required this.allTracks,
    required this.filteredTracks,
    required this.tags,
    this.selectedTagId,
    required this.isLoading,
    this.errorMessage,
    required this.downloadedTrackIds,
  });

  AlbumDetailsState copyWith({
    List<Track>? allTracks,
    List<Track>? filteredTracks,
    List<Tag>? tags,
    String? selectedTagId,
    bool? isLoading,
    String? errorMessage,
    Set<String>? downloadedTrackIds,
  }) {
    return AlbumDetailsState(
      allTracks: allTracks ?? this.allTracks,
      filteredTracks: filteredTracks ?? this.filteredTracks,
      tags: tags ?? this.tags,
      selectedTagId: selectedTagId != null ? (selectedTagId == 'all' ? null : selectedTagId) : this.selectedTagId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      downloadedTrackIds: downloadedTrackIds ?? this.downloadedTrackIds,
    );
  }

  // Helper because copyWith(selectedTagId: null) is tricky
  AlbumDetailsState resetFilter() {
    return AlbumDetailsState(
      allTracks: allTracks,
      filteredTracks: allTracks,
      tags: tags,
      selectedTagId: null,
      isLoading: isLoading,
      errorMessage: errorMessage,
      downloadedTrackIds: downloadedTrackIds,
    );
  }
}

class AlbumDetailsNotifier extends StateNotifier<AlbumDetailsState> {
  AlbumDetailsNotifier()
      : super(AlbumDetailsState(
          allTracks: [],
          filteredTracks: [],
          tags: [],
          isLoading: true,
          downloadedTrackIds: {},
        ));

  Future<void> loadAlbum(String albumId) async {
    state = state.copyWith(isLoading: true);
    try {
      final tracks = await sl.getTracksByCategoryUseCase.execute(albumId);
      
      // Calculate unique tags from all fetched tracks
      final tagsSet = <Tag>{};
      for (var track in tracks) {
        tagsSet.addAll(track.tags);
      }
      final sortedTags = tagsSet.toList()
        ..sort((a, b) => a.titleEn.compareTo(b.titleEn));

      state = state.copyWith(
        allTracks: tracks,
        filteredTracks: tracks,
        tags: sortedTags,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void filterByTag(String? tagId) {
    if (tagId == null || tagId == 'all') {
      state = state.resetFilter();
      return;
    }

    final filtered = state.allTracks.where((track) {
      return track.tags.any((tag) => tag.id == tagId);
    }).toList();

    state = state.copyWith(
      filteredTracks: filtered,
      selectedTagId: tagId,
    );
  }

  void markAsDownloaded(String trackId) {
    final newDownloadedIds = Set<String>.from(state.downloadedTrackIds)..add(trackId);
    state = state.copyWith(downloadedTrackIds: newDownloadedIds);
  }

  void removeDownload(String trackId) {
    final newDownloadedIds = Set<String>.from(state.downloadedTrackIds)..remove(trackId);
    state = state.copyWith(downloadedTrackIds: newDownloadedIds);
  }
}

final albumDetailsProvider =
    StateNotifierProvider.family<AlbumDetailsNotifier, AlbumDetailsState, String>(
  (ref, albumId) {
    final notifier = AlbumDetailsNotifier();
    notifier.loadAlbum(albumId);
    return notifier;
  },
);
