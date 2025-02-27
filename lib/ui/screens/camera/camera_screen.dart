import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../../config/constants.dart';
import '../../../core/models/recognition_result.dart';
import '../../../core/services/food_recognition_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCapturing = false;
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _capturedImageBytes;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb) {
      // We'll initialize in didChangeDependencies to access Provider
      Future.microtask(() => _initializeCamera());
    } else {
      // For web, we'll just set camera as initialized and use image picker
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is a safer place to access Provider
    if (!kIsWeb && !_isCameraInitialized) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return; // Skip for web

    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) return; // Skip for web

    try {
      // Get cameras from provider instead of calling availableCameras()
      _cameras = Provider.of<List<CameraDescription>>(context, listen: false);

      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No cameras available on this device')),
          );
        }
        setState(() {
          _isCameraInitialized =
              true; // Still mark as initialized to avoid UI issues
        });
        return;
      }

      final camera = _isRearCameraSelected
          ? _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras!.first)
          : _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras!.first);

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
        setState(() {
          _isCameraInitialized =
              true; // Still mark as initialized to avoid UI issues
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (kIsWeb) return; // Skip for web

    setState(() {
      _isCameraInitialized = false;
      _isRearCameraSelected = !_isRearCameraSelected;
    });

    await _initializeCamera();
  }

  Future<void> _captureImage() async {
    if (kIsWeb) {
      // For web, use image picker
      await _pickImage(ImageSource.camera);
      return;
    }

    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile imageFile = await _controller!.takePicture();
      _capturedImagePath = imageFile.path;

      // Read the image bytes for processing
      final bytes = await imageFile.readAsBytes();
      _capturedImageBytes = bytes;

      // Process the image for ML model
      setState(() {
        _isAnalyzing = true;
      });

      // Get the food recognition service from provider
      final foodRecognitionService =
          Provider.of<FoodRecognitionServiceInterface>(context, listen: false);

      final File file = File(imageFile.path);
      final results = await foodRecognitionService.recognizeFoodFromFile(file);

      // Navigate to results screen with the results
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/results',
          arguments: {
            'results': results,
            'imageBytes': _capturedImageBytes,
            'imagePath': _capturedImagePath,
          },
        );
      }
    } catch (e) {
      print('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
      setState(() {
        _isCapturing = false;
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _isAnalyzing = true;
      });

      // Store the image path and bytes
      _capturedImagePath = pickedFile.path;
      _capturedImageBytes = await pickedFile.readAsBytes();

      // Get the food recognition service from provider
      final foodRecognitionService =
          Provider.of<FoodRecognitionServiceInterface>(context, listen: false);

      List<RecognitionResult> results;

      if (kIsWeb) {
        // For web, use bytes directly
        results =
            await foodRecognitionService.recognizeFood(_capturedImageBytes!);
        print('Image picked: ${pickedFile.path}');
      } else {
        // For mobile, use File
        final File file = File(pickedFile.path);
        results = await foodRecognitionService.recognizeFoodFromFile(file);
      }

      // Navigate to results screen with the results
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/results',
          arguments: {
            'results': results,
            'imageBytes': _capturedImageBytes,
            'imagePath': _capturedImagePath,
          },
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return _buildAnalyzingScreen();
    }

    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // Calculate screen dimensions for square preview
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Use the smaller dimension to ensure the preview fits on screen
    final previewSize =
        screenWidth > screenHeight - 200 ? screenHeight - 200 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back button row
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Take a Photo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Camera guidance text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Position food in the center of the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Camera Preview or Web Placeholder in a square container
              Container(
                width: previewSize,
                height: previewSize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Camera preview or placeholder
                    kIsWeb
                        ? _buildWebCameraPlaceholder()
                        : (_controller != null &&
                                _controller!.value.isInitialized
                            ? ClipRect(
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Transform.scale(
                                      scale: _getPreviewScale(),
                                      child: Center(
                                        child: CameraPreview(_controller!),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Text(
                                    'Loading Camera...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )),

                    // Overlay guides
                    _buildFrameGuides(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bottom guidance text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Tap the button to identify the food',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Camera Controls
              _buildCameraControls(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate the scale to maintain aspect ratio while filling a square
  double _getPreviewScale() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return 1.0;
    }

    // Get the camera preview size
    final previewSize = _controller!.value.previewSize!;
    final cameraAspectRatio = previewSize.height / previewSize.width;

    // We want to fill a square (aspect ratio 1.0)
    // If camera is wider than tall, we need to scale up to fill height
    // If camera is taller than wide, we need to scale up to fill width
    return cameraAspectRatio > 1.0
        ? cameraAspectRatio
        : 1.0 / cameraAspectRatio;
  }

  Widget _buildWebCameraPlaceholder() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Camera icon with square frame
            Stack(
              alignment: Alignment.center,
              children: [
                // Square frame
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Camera icon
                Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Camera preview not available on web',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Take Photo'),
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  onPressed: _pickFromGallery,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameGuides() {
    return Stack(
      children: [
        // Center crosshair
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        // Corner guides
        _buildCornerGuide(Alignment.topLeft),
        _buildCornerGuide(Alignment.topRight),
        _buildCornerGuide(Alignment.bottomLeft),
        _buildCornerGuide(Alignment.bottomRight),
      ],
    );
  }

  Widget _buildCornerGuide(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: alignment == Alignment.topLeft ||
                      alignment == Alignment.topRight
                  ? Colors.white.withOpacity(0.7)
                  : Colors.transparent,
              width: 2,
            ),
            bottom: BorderSide(
              color: alignment == Alignment.bottomLeft ||
                      alignment == Alignment.bottomRight
                  ? Colors.white.withOpacity(0.7)
                  : Colors.transparent,
              width: 2,
            ),
            left: BorderSide(
              color: alignment == Alignment.topLeft ||
                      alignment == Alignment.bottomLeft
                  ? Colors.white.withOpacity(0.7)
                  : Colors.transparent,
              width: 2,
            ),
            right: BorderSide(
              color: alignment == Alignment.topRight ||
                      alignment == Alignment.bottomRight
                  ? Colors.white.withOpacity(0.7)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          IconButton(
            icon: const Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 28,
            ),
            onPressed: _pickFromGallery,
          ),

          // Capture button
          GestureDetector(
            onTap:
                kIsWeb ? () => _pickImage(ImageSource.camera) : _captureImage,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: Center(
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Switch camera button (hidden on web)
          kIsWeb
              ? const SizedBox(width: 28) // Placeholder for web
              : IconButton(
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _switchCamera,
                ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Analyzing your food...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Our AI is identifying the food, calculating nutritional information, and finding interesting facts about your meal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tip: For best results, ensure good lighting and center the food in the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
