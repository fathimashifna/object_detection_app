import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:object_detection_app/view/image_view_screen.dart';
import 'package:tflite_v2/tflite_v2.dart';

import '../utils/boundingboxes.dart';

/// A screen that performs object detection using a camera feed.
class ObjectDetectionScreen extends StatefulWidget {
  /// List of available camera descriptions.
  final List<CameraDescription> cameras;

  /// The name of the item to be detected.
  final String itemName;

  /// Constructor for [ObjectDetectionScreen].
  const ObjectDetectionScreen({super.key, required this.cameras, required this.itemName});

  @override
  State<StatefulWidget> createState() => ObjectDetectionScreenState();
}

class ObjectDetectionScreenState extends State<ObjectDetectionScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late CameraController _controller;
  bool isModelLoaded = false;
  List<dynamic>? recognitions;
  int imageHeight = 0;
  int imageWidth = 0;
  bool isFound = false;
  XFile? imageFile;
  bool isDisposed = false;
  bool isRunningModel = false;
  Timer? _detectionTimer; // Timer to check for object detection
  final int _detectionTimeout = 60; // Timer duration in seconds
  String instructions = "Move closer to the object"; // Initial instruction
  double scale = 1.0;
  double offsetX = 0.0;
  double offsetY = 0.0;
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  // Track object detection over multiple frames
  int detectionCount = 0;
  final int detectionThreshold = 5; // Number of frames to confirm detection

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadModel();
    initializeCamera(widget.cameras[0]);
    startDetectionTimer();

    // Initialize animation controller and animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detectionTimer?.cancel(); // Cancel the detection timer
    if (_controller != null && _controller.value.isInitialized) {
      _controller.dispose();
    }
    _animationController.dispose();
    isDisposed = true;
    _overlayEntry?.remove(); // remove the overlay
    super.dispose();
  }

  /// Starts the timer to periodically check for object detection.
  void startDetectionTimer() {
    _detectionTimer = Timer.periodic(Duration(seconds: _detectionTimeout), (timer) {
      if (!isFound) {
        _objectNotFound();
      }
    });
  }

  /// Handles app lifecycle state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      cameraController.dispose();
        isDisposed = true;
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (isDisposed) {
        isDisposed = false;
        initializeCamera(cameraController.description);

      }
    }
  }

  /// Loads the object detection model.
  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: 'assets/object_files/detect.tflite',
      labels: 'assets/object_files/labelmap.txt',
    );
    if (mounted) {
      setState(() {
        isModelLoaded = res != null;
      });
    }
  }

  /// Toggles between the front and back cameras.
  void toggleCamera() {
    if (_controller == null || !_controller.value.isInitialized) return;

    final lensDirection = _controller.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = widget.cameras.firstWhere((description) =>
      description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = widget.cameras.firstWhere((description) =>
      description.lensDirection == CameraLensDirection.front);
    }

    if (newDescription != null) {
      _controller.dispose();
      setState(() {
        isDisposed = false;
      });
      initializeCamera(newDescription);
    } else {
      //print('Requested camera not available');
      Fluttertoast.showToast(
        msg: "Requested camera not available!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  /// Initializes the camera with the given description.
  void initializeCamera(CameraDescription description) async {
    if (isDisposed) return;

    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller.initialize();

      if (!mounted) return;

      _controller.startImageStream((CameraImage image) {
        if (!isDisposed && isModelLoaded && !isRunningModel) {
          runImageModel(image);
        }
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error initializing camera: $e");
      Fluttertoast.showToast(
        msg: "Camera initialization error!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  /// Runs the object detection model on the given camera image.
  void runImageModel(CameraImage image) async {
    if (image.planes.isEmpty) return;

    setState(() {
      isRunningModel = true; // Set the flag to indicate the model is running
    });

    var recognition = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      model: 'SSDMobileNet',
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );

    if (mounted) {
      setState(() {
        recognitions = recognition;
        imageHeight = image.height;
        imageWidth = image.width;
      });
    }

    bool found = false; // Track if the object is found

    if (recognitions != null) {
      double objectSizeThreshold = 0.2; // Example threshold for object size
      double objectCenterThreshold = 0.1; // Example threshold for object center alignment

      for (var rec in recognitions!) {
        if (rec["detectedClass"].toString() == widget.itemName) {
          double objectWidth = rec["rect"]["w"];
          double objectHeight = rec["rect"]["h"];
          double objectCenterX = rec["rect"]["x"] + objectWidth / 2;
          double objectCenterY = rec["rect"]["y"] + objectHeight / 2;

          // Check the object size and position to give feedback
          if (objectWidth < objectSizeThreshold && objectHeight < objectSizeThreshold) {
            updateInstructions("Move closer to the object");
          } else if (objectWidth > objectSizeThreshold * 2 && objectHeight > objectSizeThreshold * 2) {
            updateInstructions("Move farther from the object");
          } else if ((objectCenterX - 0.5).abs() > objectCenterThreshold || (objectCenterY - 0.5).abs() > objectCenterThreshold) {
            updateInstructions("Center the object in the frame");
          } else {
            updateInstructions("Object in position");
            found = true; // Set found to true if object is detected
            detectionCount++;
            break; // Exit the loop once the object is found
          }
        }
      }

      if (!found) {
        detectionCount = 0; // Reset detection count if not found
      }
    }

    if (detectionCount >= detectionThreshold) {
      if (mounted) {
        setState(() {
          isFound = true;
        });
        await _captureAndNavigate(); // Capture image and navigate
      }
    }

    if (mounted) {
      setState(() {
        isRunningModel = false; // Reset the flag after the model has run
      });
    }
  }

  /// Captures the image and navigates to the [ImageViewScreen] with the captured image.
  Future<void> _captureAndNavigate() async {
    try {
      // Hide overlay before capturing image
      _overlayEntry?.remove();
      _overlayEntry = null;

      if (_controller.value.isInitialized) {
        final XFile picture = await _controller.takePicture();
        DateTime now = DateTime.now();
        var formatter = DateFormat('dd/MM/yyyy');
        String formattedDate = formatter.format(now);

        if (mounted) {
          setState(() {
            imageFile = picture;
          });
        }

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewScreen(
              imagePath: imageFile!.path,
              imageName: widget.itemName,
              timeStamp: now,
              date: formattedDate,
            ),
          ),
        );
        setState(() {
          isDisposed = true;
        });

        _controller.dispose();
      }
    } catch (e) {
      print("Error taking picture: $e");
      Fluttertoast.showToast(
        msg: "Error taking picture!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  /// Displays a toast message when the object is not found and pops the current screen.
  void _objectNotFound() {
    if (!mounted || isFound) return; // Check if the widget is still mounted and object is not found
    Fluttertoast.showToast(
      msg: "Object not found!!.. Please choose another!!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    Navigator.pop(context);
    if (_controller.value.isInitialized) {
      setState(() {
        isDisposed = true;
      });
      _controller.dispose();
    }
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
  }

  /// Updates the instructions with an animated overlay.
  void updateInstructions(String newInstructions) {
    if (instructions != newInstructions) {
      setState(() {
        instructions = newInstructions;
      });

      if (_overlayEntry != null) {
        _overlayEntry!.remove();
      }

      _overlayEntry = _createOverlayEntry();
      Overlay.of(context)?.insert(_overlayEntry!);
      _animationController.forward(from: 0);
    }
  }

  /// Creates an overlay entry with animated instructions.
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                instructions,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
      ),
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            scale = details.scale;
            offsetX = details.localFocalPoint.dx;
            offsetY = details.localFocalPoint.dy;
          });
        },
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Stack(
                children: [
                  if (_controller != null && _controller.value.isInitialized && !isDisposed)
                    CameraPreview(_controller),
                  if (recognitions != null)
                    Positioned(
                      left: offsetX,
                      top: offsetY,
                      child: Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: BoundingBoxes(
                            recognitions: recognitions!,
                            previewH: imageHeight.toDouble(),
                            previewW: imageWidth.toDouble(),
                            screenH: MediaQuery.of(context).size.height * 0.8,
                            screenW: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    toggleCamera();
                  },
                  icon: Icon(
                    Icons.flip_camera_ios_outlined,
                    size: 30,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    isFound ? 'Detected' : 'Detecting ${widget.itemName}',
                    style: GoogleFonts.inter(color: Colors.red, fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}