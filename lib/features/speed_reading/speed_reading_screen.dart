import 'package:flutter/material.dart';

class SpeedReadingScreen extends StatelessWidget {
  const SpeedReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Reading"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.chrome_reader_mode_rounded, 
                size: 80, 
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                "Speed Reading Training Screen",
                textAlign: TextAlign.center,
                style: TextStyle(
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
