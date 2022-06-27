// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// A Row of buttons controlling the audio
class PlayerButtons extends StatelessWidget {
  const PlayerButtons(this._audioPlayer, {Key? key}) : super(key: key);
  final AudioPlayer _audioPlayer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Shuffle
        StreamBuilder<bool>(
          stream: _audioPlayer.shuffleModeEnabledStream,
          builder: (context, snapshot) {
            return _shuffleButton(context, snapshot.data ?? false);
          },
        ),

        /// Previous
        StreamBuilder<SequenceState?>(
          stream: _audioPlayer.sequenceStateStream,
          builder: (_, __) {
            return _previousButton();
          },
        ),

        /// Play/Pause/Restart
        StreamBuilder<PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (_, snapshot) {
            final playerState = snapshot.data;
            return _playPauseButton(playerState!);
          },
        ),

        /// Next
        StreamBuilder<SequenceState?>(
          stream: _audioPlayer.sequenceStateStream,
          builder: (_, __) {
            return _nextButton();
          },
        ),

        /// Repeat loop mode
        StreamBuilder<LoopMode>(
          stream: _audioPlayer.loopModeStream,
          builder: (context, snapshot) {
            return _repeatButton(context, snapshot.data ?? LoopMode.off);
          },
        )
      ],
    );
  }

  /// Enable or disable shuffling
  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? Icon(
              Icons.shuffle,
              color: Theme.of(context).colorScheme.secondary,
            )
          : Icon(Icons.shuffle),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          await _audioPlayer.shuffle();
        }
      },
    );
  }

  /// Seek to the previous track if it exists
  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous),
      onPressed: _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null,
    );
  }

  /// Seek to the next track if it exists
  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      onPressed: _audioPlayer.hasNext ? _audioPlayer.seekToNext : null,
    );
  }

  /// Toggles the repeat loop mode
  /// The modes are
  /// 1. not repeating
  /// 2. repeating the entire list
  /// 3. repeating the current track
  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat),
      Icon(Icons.repeat, color: Theme.of(context).colorScheme.secondary),
      Icon(Icons.repeat_one, color: Theme.of(context).colorScheme.secondary)
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        _audioPlayer.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }

  /// Play/Pause button
  /// If an audio is playing, the pause icon is shown
  /// If the audio has finished, the restart icon is shown
  /// If the audio is paused or not started yet, the play icon is shown
  /// If the audio is loading, a round progress indicator is shown
  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(),
      );
    } else if (_audioPlayer.playing != true) {
      return IconButton(
        onPressed: _audioPlayer.play,
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: _audioPlayer.pause,
      );
    } else {
      return IconButton(
        onPressed: () => _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.effectiveIndices?.first),
        icon: Icon(Icons.replay),
        iconSize: 64.0,
      );
    }
  }
}
