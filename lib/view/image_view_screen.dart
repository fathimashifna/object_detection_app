import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A screen that displays an image along with its details such as the name, date, and timestamp.
class ImageViewScreen extends StatefulWidget {
  /// The path of the image file to display.
  final String imagePath;

  /// The name of the detected object.
  final String imageName;

  /// The timestamp when the image was captured.
  final DateTime timeStamp;

  /// The date when the image was captured.
  final String date;

  /// Creates an instance of [ImageViewScreen].
  const ImageViewScreen({
    super.key,
    required this.imagePath,
    required this.imageName,
    required this.timeStamp,
    required this.date,
  });

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detected'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display the captured image
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: Image.file(File(widget.imagePath)),
            ),
            // Display the name of the detected object
            Text(
              'Object - ${widget.imageName}',
              style: GoogleFonts.inter(color: Colors.red, fontSize: 15),
            ),
            // Display the date when the image was captured
            Text(
              'Date - ${widget.date}',
              style: GoogleFonts.inter(color: Colors.red, fontSize: 15),
            ),
            // Display the timestamp when the image was captured
            Text(
              'Time -  ${widget.timeStamp.hour}:${widget.timeStamp.minute}:${widget.timeStamp.second}.${widget.timeStamp.millisecond}',
              style: GoogleFonts.inter(color: Colors.red, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}