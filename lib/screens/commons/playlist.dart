import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// A list of tiles showing all the audio sources in the audio_player
///
/// Audio sources are listed with a ListTile with the artwork and the title
class Playlist extends StatelessWidget {
  const Playlist(this._audioPlayer, {Key? key}) : super(key: key);
  final AudioPlayer _audioPlayer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final sequence = state?.sequence ?? [];
        return ListView(
          children: [
            for (var i = 0; i < sequence.length; i++)
              ListTile(
                selected: i == state?.currentIndex,
                leading: Image.network(sequence[i].tag.artwork),
                title: Text(sequence[i].tag.title),
                onTap: () {
                  _audioPlayer.seek(Duration.zero, index: i);
                },
              )
          ],
        );
      },
    );
  }
}
