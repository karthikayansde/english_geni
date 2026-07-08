import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;
  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_fill, 
                size: 80, 
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                "Playing Video From Path:\n$videoPath",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
