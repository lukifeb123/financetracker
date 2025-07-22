import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/gemini_service.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/receipt_result_widget.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _imagePicker = ImagePicker();

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  Map<String, dynamic>? _extractedData;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorMessage('Kamera tidak tersedia');
        return;
      }

      final camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      _showErrorMessage('Gagal menginisialisasi kamera: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'close',
            color: Colors.white,
            size: 6.w,
          ),
        ),
      ),
      title: Text(
        'Scan Struk',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _pickImageFromGallery,
          icon: Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'photo_library',
              color: Colors.white,
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildBody() {
    if (_extractedData != null) {
      return ReceiptResultWidget(
        extractedData: _extractedData!,
        capturedImage: _capturedImage,
        onSave: _saveTransaction,
        onRetake: _retakePhoto,
        onEdit: _editTransaction,
      );
    }

    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 3.h),
            Text(
              'Menganalisis struk...',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'AI sedang membaca dan mengekstrak data dari struk Anda',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 2.h),
            Text(
              'Menginisialisasi kamera...',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return CameraPreviewWidget(
      controller: _cameraController!,
    );
  }

  Widget _buildBottomControls() {
    if (_extractedData != null || _isProcessing) {
      return SizedBox.shrink();
    }

    return CameraControlsWidget(
      onCapture: _capturePhoto,
      onGallery: _pickImageFromGallery,
      onFlashToggle: _toggleFlash,
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      HapticFeedback.heavyImpact();
      final XFile photo = await _cameraController!.takePicture();
      await _processImage(File(photo.path));
    } catch (e) {
      _showErrorMessage('Gagal mengambil foto: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        HapticFeedback.lightImpact();
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorMessage('Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _capturedImage = XFile(imageFile.path);
    });

    try {
      final result = await _geminiService.client.analyzeReceipt(imageFile);

      try {
        final extractedData = jsonDecode(result);

        if (extractedData.containsKey('error')) {
          throw Exception(extractedData['error']);
        }

        setState(() {
          _extractedData = extractedData;
          _isProcessing = false;
        });

        HapticFeedback.mediumImpact();
        _showSuccessMessage('Struk berhasil dianalisis');
      } catch (e) {
        throw Exception('Format respons tidak valid: ${e.toString()}');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorMessage('Gagal menganalisis struk: ${e.toString()}');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      final flashMode = _cameraController!.value.flashMode;
      await _cameraController!.setFlashMode(
        flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off,
      );
      HapticFeedback.lightImpact();
    } catch (e) {
      _showErrorMessage('Gagal mengubah flash: ${e.toString()}');
    }
  }

  void _retakePhoto() {
    setState(() {
      _extractedData = null;
      _capturedImage = null;
    });
  }

  void _editTransaction(Map<String, dynamic> updatedData) {
    setState(() {
      _extractedData = updatedData;
    });
  }

  Future<void> _saveTransaction(Map<String, dynamic> transactionData) async {
    try {
      // Add additional transaction data
      final completeTransaction = {
        ...transactionData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'expense', // Receipts are typically expenses
        'receiptImage': _capturedImage?.path,
        'createdAt': DateTime.now().toIso8601String(),
        'aiGenerated': true,
      };

      // Simulate saving to database
      await Future.delayed(Duration(milliseconds: 1000));

      HapticFeedback.heavyImpact();
      _showSuccessMessage('Transaksi berhasil disimpan');

      // Navigate back to dashboard
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard-home',
        (route) => false,
      );
    } catch (e) {
      _showErrorMessage('Gagal menyimpan transaksi: ${e.toString()}');
    }
  }

  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.getSuccessColor(true),
      textColor: Colors.white,
    );
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: Colors.white,
    );
  }
}
