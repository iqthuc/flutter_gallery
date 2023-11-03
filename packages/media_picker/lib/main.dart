import 'package:flutter/material.dart';
import 'package:media_picker/media_picker/media_picker_widget.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeApp(),
    );
  }
}

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaPicker(
      onPick: (value) {},
      onCancel: () {},
      captureCamera: (value) {},
    );
  }
}
