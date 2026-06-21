import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loml_nas_music/features/player/player_provider.dart';
import 'package:loml_nas_music/data/models/models.dart';

void main() {
  late PlayerState player;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (call) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async => null,
    );
    player = PlayerState();
  });

  tearDown(() {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'), null);
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'), null);
  });

  Song s(String id, {String title = 'Song', String? artist}) {
    return Song(id: id, title: title, artist: artist);
  }

  group('queue management', () {
    test('starts empty', () {
      expect(player.hasCurrent, isFalse);
      expect(player.queue, isEmpty);
      expect(player.isPlaying, isFalse);
    });

    test('playSong sets current song', () async {
      await player.playSong(s('1', title: 'Test'));
      expect(player.hasCurrent, isTrue);
      expect(player.currentSong?.id, '1');
      expect(player.currentTitle, 'Test');
      expect(player.queue.length, 1);
    });

    test('playList sets queue and plays at startIndex', () async {
      await player.playList([s('1'), s('2'), s('3')], startIndex: 1);
      expect(player.currentIndex, 1);
      expect(player.currentSong?.id, '2');
      expect(player.queue.length, 3);
    });

    test('addToQueue appends song', () async {
      await player.playSong(s('1'));
      player.addToQueue(s('2'));
      expect(player.queue.length, 2);
      expect(player.queue[1].id, '2');
    });

    test('addToQueueNext inserts after current', () async {
      await player.playSong(s('1'));
      player.addToQueueNext(s('2'));
      expect(player.queue[1].id, '2');
    });

    test('removeFromQueue removes song', () async {
      await player.playList([s('1'), s('2'), s('3')]);
      player.removeFromQueue(1);
      expect(player.queue.length, 2);
      expect(player.queue[1].id, '3');
    });

    test('removeFromQueue adjusts currentIndex', () async {
      await player.playList([s('1'), s('2'), s('3')], startIndex: 1);
      player.removeFromQueue(0);
      expect(player.currentIndex, 0);
      expect(player.currentSong?.id, '2');
    });

    test('clearQueue resets everything', () async {
      await player.playSong(s('1'));
      await player.clearQueue();
      expect(player.hasCurrent, isFalse);
      expect(player.queue, isEmpty);
    });
  });

  group('shuffle', () {
    test('toggleShuffle keeps current song at index 0', () async {
      await player.playList([s('1'), s('2'), s('3'), s('4')], startIndex: 0);
      player.toggleShuffle();
      expect(player.isShuffled, isTrue);
      expect(player.currentSong?.id, '1');
      expect(player.queue.length, 4);
    });

    test('toggleShuffle restores original order', () async {
      final songs = [s('1'), s('2'), s('3')];
      await player.playList(songs);
      player.toggleShuffle();
      player.toggleShuffle();
      expect(player.isShuffled, isFalse);
      expect(player.currentSong?.id, '1');
    });
  });

  group('repeat mode', () {
    test('default is all', () {
      expect(player.repeatMode, PlayerRepeatMode.all);
    });

    test('cyclePlayerRepeatMode cycles through modes', () {
      player.cyclePlayerRepeatMode();
      expect(player.repeatMode, PlayerRepeatMode.one);
      player.cyclePlayerRepeatMode();
      expect(player.repeatMode, PlayerRepeatMode.none);
      player.cyclePlayerRepeatMode();
      expect(player.repeatMode, PlayerRepeatMode.all);
    });
  });

  group('empty queue guards', () {
    test('next does nothing when queue empty', () async {
      await player.next();
      expect(player.hasCurrent, isFalse);
    });

    test('previous does nothing when queue empty', () async {
      await player.previous();
      expect(player.hasCurrent, isFalse);
    });

    test('togglePlayPause does nothing when no current song', () async {
      await player.togglePlayPause();
      expect(player.isPlaying, isFalse);
    });

    test('reorderQueue reorders songs', () async {
      await player.playList([s('1'), s('2'), s('3')]);
      player.reorderQueue(0, 2);
      expect(player.queue[0].id, '2');
      expect(player.queue[1].id, '1');
      expect(player.queue[2].id, '3');
    });
  });
}
