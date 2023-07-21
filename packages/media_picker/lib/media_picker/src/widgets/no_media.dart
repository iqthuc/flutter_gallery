import 'package:flutter/material.dart';

class NoMedia extends StatelessWidget {
  const NoMedia({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.image_not_supported_outlined,
              size: 50,
            ),
            SizedBox(height: 20),
            Text(
              'No Images Available',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
