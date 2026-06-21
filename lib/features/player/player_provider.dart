import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import '../../data/models/models.dart';
import '../../core/api/subsonic_api.dart';

class PlayerState extends ChangeNotifier {
  final audio.AudioPlayer _player;
  final SubsonicApi? _api;

  PlayerState({SubsonicApi? api, audio.AudioPlayer? player})
      : _player = player ?? audio.AudioPlayer(),
        _api = api {
    _player.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });
    _player.onPlayerStateChanged.listen((state) {
      final wasPlaying = _isPlaying;
      final wasCompleted = _playerState == audio.PlayerState.completed;
      _playerState = state;
      _isPlaying = state == audio.PlayerState.playing;
      if (wasPlaying && state == audio.PlayerState.completed) {
        _onTrackEnd();
      }
      if (wasPlaying != _isPlaying) {
        notifyListeners();
      }
    });
  }

  List<Song> _queue = [];
  List<Song> _originalQueue = [];
  int _currentIndex = -1;
  bool _isShuffled = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.all;
  bool _isPlaying = false;
  bool _isTransitioning = false;
  audio.PlayerState _playerState = audio.PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  List<Song> get queue => List.unmodifiable(_queue);
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _queue.length ? _queue[_currentIndex] : null;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isShuffled => _isShuffled;
  bool get hasCurrent => currentSong != null;
  PlayerRepeatMode get repeatMode => _repeatMode;
  Duration get position => _position;
  Duration get duration => _duration;
  double get progress => _duration.inMilliseconds > 0 ? _position.inMilliseconds / _duration.inMilliseconds : 0.0;
  String get currentTitle => currentSong?.title ?? '';
  String get currentArtist => currentSong?.artist ?? '';
  String? get currentCoverArt => currentSong?.coverArt;
  String? get currentAlbumId => currentSong?.albumId;
  String? get currentSongId => currentSong?.id;

  void _fireAsync(Future<void> Function() fn) {
    fn().catchError((e, stack) {
      debugPrint('[PlayerState] Unhandled async error: $e\n$stack');
    });
  }

  Future<void> _playCurrent() async {
    final song = currentSong;
    if (song == null || _api == null) return;
    if (_isTransitioning) return;
    _isTransitioning = true;
    final startedSongId = song.id;
    try {
      final url = _api.getStreamUrl(song.id);
      debugPrint('[PlayerState] Playing: ${song.title} url=$url');
      await _player.play(audio.UrlSource(url));
    } catch (e, stack) {
      if (currentSong?.id != startedSongId) return;
      debugPrint('[PlayerState] Error playing ${song.title}: $e\n$stack');
      try { await _player.stop(); } catch (_) {}
      try { await next(); } catch (_) {}
    } finally {
      _isTransitioning = false;
    }
  }

  void _onTrackEnd() {
    if (_currentIndex < 0) {
      debugPrint('[PlayerState] _onTrackEnd skipped: idx<0');
      return;
    }
    debugPrint('[PlayerState] _onTrackEnd: idx=$_currentIndex len=${_queue.length} repeat=$_repeatMode');
    try {
      switch (_repeatMode) {
        case PlayerRepeatMode.one:
          _fireAsync(_playCurrent);
        case PlayerRepeatMode.all:
          _currentIndex = (_currentIndex + 1) % _queue.length;
          _fireAsync(_playCurrent);
          notifyListeners();
        case PlayerRepeatMode.none:
          if (_queue.length == 1) {
            _fireAsync(_playCurrent);
          } else if (_currentIndex + 1 < _queue.length) {
            _currentIndex++;
            _fireAsync(_playCurrent);
            notifyListeners();
          } else {
            _stop();
          }
      }
    } catch (e, stack) {
      debugPrint('[PlayerState] _onTrackEnd error: $e\n$stack');
    }
  }

  Future<void> playSong(Song song) async {
    _queue = [song];
    _originalQueue = [song];
    _currentIndex = 0;
    await _playCurrent();
    notifyListeners();
  }

  Future<void> playList(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    _queue = List.from(songs);
    _originalQueue = List.from(songs);
    _currentIndex = startIndex;
    await _playCurrent();
    notifyListeners();
  }

  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
    notifyListeners();
  }

  void addToQueueNext(Song song) {
    final insertIndex = _currentIndex + 1;
    _queue.insert(insertIndex > _queue.length ? _queue.length : insertIndex, song);
    _originalQueue.insert(insertIndex > _originalQueue.length ? _originalQueue.length : insertIndex, song);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    final wasCurrent = index == _currentIndex;
    _queue.removeAt(index);
    _originalQueue.removeAt(index);
    if (_currentIndex > index) {
      _currentIndex--;
    } else if (_currentIndex == index) {
      if (_queue.isEmpty) {
        _stop();
      } else if (_currentIndex >= _queue.length) {
        _currentIndex = _queue.length - 1;
        _fireAsync(_playCurrent);
      } else if (wasCurrent) {
        _fireAsync(_playCurrent);
      }
    }
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _queue.length || newIndex < 0 || newIndex >= _queue.length) return;
    if (oldIndex < newIndex) newIndex--;
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);
    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (!hasCurrent) return;
    if (_playerState == audio.PlayerState.completed) {
      await _playCurrent();
    } else if (_isPlaying) {
      _player.pause();
    } else {
      _player.resume();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    if (!hasCurrent) return;
    await _player.resume();
  }

  Future<void> next() async {
    if (_queue.isEmpty || _currentIndex < 0) {
      debugPrint('[PlayerState] next skipped: empty=${_queue.isEmpty} idx=$_currentIndex');
      return;
    }
    if (_queue.length == 1) {
      debugPrint('[PlayerState] next: single song queue, replay current');
      await _playCurrent();
      return;
    }
    final nextIndex = _currentIndex + 1;
    debugPrint('[PlayerState] next: idx=$_currentIndex nextIdx=$nextIndex len=${_queue.length} repeat=$_repeatMode');
    if (nextIndex >= _queue.length) {
      if (_repeatMode == PlayerRepeatMode.all) {
        debugPrint('[PlayerState] next: wrap to first (repeat all)');
        _currentIndex = 0;
      } else {
        debugPrint('[PlayerState] next: stop at end');
        _stop();
        return;
      }
    } else {
      _currentIndex = nextIndex;
    }
    await _playCurrent();
    notifyListeners();
  }

  Future<void> previous() async {
    if (_queue.isEmpty || _currentIndex < 0) return;
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final prevIndex = _currentIndex - 1;
    if (prevIndex < 0) {
      if (_repeatMode == PlayerRepeatMode.all) {
        _currentIndex = _queue.length - 1;
      } else {
        await _player.seek(Duration.zero);
        return;
      }
    } else {
      _currentIndex = prevIndex;
    }
    await _playCurrent();
    notifyListeners();
  }

  Future<void> seekTo(double value) async {
    if (!hasCurrent) return;
    await _player.seek(Duration(milliseconds: (value * _duration.inMilliseconds).round()));
  }

  void toggleShuffle() {
    if (!hasCurrent) return;
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      final current = _queue[_currentIndex];
      final rest = [..._queue]..removeAt(_currentIndex);
      rest.shuffle();
      _queue = [current, ...rest];
      _currentIndex = 0;
    } else {
      final currentId = currentSong?.id;
      _queue = List.from(_originalQueue);
      _currentIndex = _queue.indexWhere((s) => s.id == currentId);
      if (_currentIndex < 0) _currentIndex = 0;
    }
    notifyListeners();
  }

  void cyclePlayerRepeatMode() {
    const modes = [PlayerRepeatMode.none, PlayerRepeatMode.all, PlayerRepeatMode.one];
    final nextIndex = (modes.indexOf(_repeatMode) + 1) % modes.length;
    _repeatMode = modes[nextIndex];
    notifyListeners();
  }

  String get repeatModeIcon => switch (_repeatMode) {
    PlayerRepeatMode.all => 'repeat',
    PlayerRepeatMode.one => 'repeat_one',
    PlayerRepeatMode.none => 'repeat',
  };

  Future<void> clearQueue() async {
    await _stop();
    _queue = [];
    _originalQueue = [];
    notifyListeners();
  }

  Future<void> _stop() async {
    _currentIndex = -1;
    _position = Duration.zero;
    _duration = Duration.zero;
    await _player.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

enum PlayerRepeatMode { none, all, one }
