import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForSequenceStateChanges();
    _listenForPositionChanges();
  }

  Future<void> load(List<MediaItem> items, {int initialIndex = 0}) async {
    queue.add(items);
    await _playlist.clear();
    final sources = items.map((m) => AudioSource.uri(Uri.parse(m.id))).toList();
    await _playlist.addAll(sources);
    try {
      await _player.setAudioSource(_playlist, initialIndex: initialIndex);
      mediaItem.add(items[initialIndex]);
    } catch (_) {}
  }

  Future<void> selectIndex(int index) async {
    if (index < 0 || index >= (_playlist.length)) return;
    await _player.seek(Duration.zero, index: index);
    if (index < queue.value.length) mediaItem.add(queue.value[index]);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((d) {
      final item = mediaItem.value;
      if (item == null) return;
      mediaItem.add(item.copyWith(duration: d));
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((state) {
      final seq = state?.sequence;
      final idx = state?.currentIndex ?? 0;
      if (seq == null || idx < 0 || idx >= queue.value.length) return;
      if (idx < queue.value.length) mediaItem.add(queue.value[idx]);
    });
  }

  void _listenForPositionChanges() {
    // Push frequent position updates so UI progress and system notification stay in sync
    _player.positionStream.listen((pos) {
      playbackState.add(playbackState.value.copyWith(updatePosition: pos));
    });
  }
}

Future<MyAudioHandler> initMyAudioHandler() {
  return AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.myapp.nim.channel.audio',
      androidNotificationChannelName: 'Nim Audio Service',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}
