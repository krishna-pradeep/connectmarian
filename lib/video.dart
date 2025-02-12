import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BackgroundVideoPage(),
    );
  }
}

class BackgroundVideoPage extends StatefulWidget {
  @override
  _BackgroundVideoPageState createState() => _BackgroundVideoPageState();
}

class _BackgroundVideoPageState extends State<BackgroundVideoPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    const videoId = 'dQw4w9WgXcQ'; // Replace with your YouTube video ID
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        loop: true,
        mute: true,
        hideControls: true,
        hideThumbnail: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: false,
            progressColors: ProgressBarColors(
              playedColor: Colors.transparent,
              handleColor: Colors.transparent,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3), // Optional overlay
          ),
          Center(
            child: Text(
              'Overlay Content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
