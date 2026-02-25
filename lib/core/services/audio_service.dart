import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../network/supabase_service.dart';
import '../../domain/entities/track.dart';
import '../../data/models/track_model.dart';
import '../utils/logger.dart';

class AudioService {
  final SupabaseService _supabaseService;
  final Logger _logger;
  AudioPlayer? _audioPlayer;
  Track? _currentTrack;
  bool _isPlaying = false;
  bool _isLoading = false;

  // Stream controllers
  final _currentTrackController = StreamController<Track?>.broadcast();
  final _isPlayingController = StreamController<bool>.broadcast();
  final _isLoadingController = StreamController<bool>.broadcast();

  AudioService(this._supabaseService, this._logger) {
    _initAudioPlayer();
  }

  // Getters
  Stream<Track?> get currentTrackStream => _currentTrackController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<bool> get isLoadingStream => _isLoadingController.stream;
  Track? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer!.playerStateStream.listen((state) {
      if (state.playing) {
        _isPlaying = true;
      } else if (state.processingState == ProcessingState.completed || !state.playing) {
        _isPlaying = false;
      }
      _isPlayingController.add(_isPlaying);
    });
  }

  // Track operations
  Future<List<Track>> getTopTracks({int limit = 10}) async {
    try {
      _setLoading(true);
      final response = await _supabaseService.fetchTopTracks(limit: limit);
      
      final tracks = response;
      
      _setLoading(false);
      return tracks;
    } catch (e) {
      _logger.error('Failed to get top tracks: $e');
      _setLoading(false);
      return [];
    }
  }

  Future<List<Track>> searchTracks(String query) async {
    try {
      _setLoading(true);
      final response = await _supabaseService.searchTracks(query);
      
      final tracks = response.map((trackMap) {
        final model = TrackModel.fromJson(trackMap);
        return Track(
          id: model.id,
          categoryId: model.categoryId,
          title: model.getLocalizedName('en'),
          subtitle: model.getLocalizedSubtitle('en'),
          description: model.getLocalizedDescription('en'),
          speaker: model.getLocalizedSpeaker('en'),
          coverImageUrl: model.coverImageUrl,
          audioUrl: model.audioUrl,
          durationSeconds: model.durationSeconds,
          publishedAt: model.publishedAt,
          isActive: model.isActive,
          createdAt: model.createdAt,
          updatedAt: model.updatedAt,
        );
      }).toList();
      
      _setLoading(false);
      return tracks;
    } catch (e) {
      _logger.error('Failed to search tracks: $e');
      _setLoading(false);
      return [];
    }
  }

  Future<void> playTrack(Track track) async {
    try {
      _setLoading(true);
      
      if (_audioPlayer == null) {
        _initAudioPlayer();
      }

      if (track.audioUrl != null) {
        await _audioPlayer!.setUrl(track.audioUrl!);
        await _audioPlayer!.play();
        
        _currentTrack = track;
        _isPlaying = true;
        
        _currentTrackController.add(_currentTrack);
        _isPlayingController.add(_isPlaying);
        
        _logger.info('Playing track: ${track.title}');
      }
    } catch (e) {
      _logger.error('Failed to play track: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pauseTrack() async {
    try {
      if (_audioPlayer != null && _isPlaying) {
        await _audioPlayer!.pause();
        _isPlaying = false;
        _isPlayingController.add(_isPlaying);
        _logger.info('Track paused');
      }
    } catch (e) {
      _logger.error('Failed to pause track: $e');
    }
  }

  Future<void> resumeTrack() async {
    try {
      if (_audioPlayer != null && !_isPlaying && _currentTrack != null) {
        await _audioPlayer!.play();
        _isPlaying = true;
        _isPlayingController.add(_isPlaying);
        _logger.info('Track resumed');
      }
    } catch (e) {
      _logger.error('Failed to resume track: $e');
    }
  }

  Future<void> stopTrack() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        _isPlaying = false;
        _currentTrack = null;
        
        _currentTrackController.add(_currentTrack);
        _isPlayingController.add(_isPlaying);
        
        _logger.info('Track stopped');
      }
    } catch (e) {
      _logger.error('Failed to stop track: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.seek(position);
        _logger.info('Seeked to: ${position.inSeconds}s');
      }
    } catch (e) {
      _logger.error('Failed to seek: $e');
    }
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _isLoadingController.add(_isLoading);
  }

  void dispose() {
    _audioPlayer?.dispose();
    _currentTrackController.close();
    _isPlayingController.close();
    _isLoadingController.close();
  }
}
