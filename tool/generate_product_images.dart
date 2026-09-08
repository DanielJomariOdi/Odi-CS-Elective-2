import 'dart:io';
import 'dart:ui' as ui;

import 'package:act_1/data/item_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Run with `flutter test tool/generate_product_images.dart` when icons change.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Generate bundled placeholder product images', () async {
    final loader = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await loader.load();
    await Directory('assets/images').create(recursive: true);

    for (final item in items) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(item.icon.codePoint),
          style: TextStyle(
            fontFamily: item.icon.fontFamily,
            fontSize: 160,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset((256 - painter.width) / 2, (256 - painter.height) / 2),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(256, 256);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('assets/images/${item.id}.png').writeAsBytes(
        bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      painter.dispose();
      picture.dispose();
      image.dispose();
    }
  });
}
