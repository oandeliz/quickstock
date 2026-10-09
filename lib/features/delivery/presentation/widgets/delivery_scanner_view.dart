import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quickstock/features/delivery/presentation/providers/delivery_notifier.dart';

class DeliveryScannerView extends ConsumerStatefulWidget {
  final String orderId;

  const DeliveryScannerView({super.key, required this.orderId});

  @override
  ConsumerState<DeliveryScannerView> createState() => _DeliveryScannerViewState();
}

class _DeliveryScannerViewState extends ConsumerState<DeliveryScannerView> {
  late final MobileScannerController controller;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _processToken(String token, {required String orderId}) async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
    });

    final success = await ref
        .read(deliveryNotifierProvider.notifier)
        .verifyAndDeliver(
          orderId: orderId,
          scannedToken: token,
        );

    if (success) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid token.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _resetProcessing();
    }
  }

  void _resetProcessing() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final rawValue = barcode!.rawValue!;
    String extractedOrderId = widget.orderId;
    String extractedToken = rawValue;

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('orderId')) {
          extractedOrderId = decoded['orderId'].toString();
        }
        if (decoded.containsKey('token')) {
          extractedToken = decoded['token'].toString();
        }
      }
    } catch (_) {
      // Fallback to plain token format
    }

    _processToken(extractedToken, orderId: extractedOrderId);
  }

  void _showManualEntryDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Token Manually'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: '6-character token',
              border: OutlineInputBorder(),
            ),
            maxLength: 6,
            textCapitalization: TextCapitalization.characters,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final token = textController.text.trim();
                if (token.isNotEmpty) {
                  Navigator.of(context).pop();
                  _processToken(token, orderId: widget.orderId);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Delivery QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Positioned.fill(
            child: Container(
              decoration: ShapeDecoration(
                shape: _ScannerOverlayShape(
                  borderColor: Theme.of(context).primaryColor,
                  borderWidth: 4.0,
                  overlayColor: Colors.black54,
                  borderRadius: 16.0,
                  cutoutSize: const Size(250, 250),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _showManualEntryDialog,
                icon: const Icon(Icons.keyboard),
                label: const Text('Enter Token Manually'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final Size cutoutSize;

  const _ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.overlayColor = const Color(0x88000000),
    this.borderRadius = 0,
    this.cutoutSize = const Size(200, 200),
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutoutRect = Rect.fromCenter(
      center: rect.center,
      width: cutoutSize.width,
      height: cutoutSize.height,
    );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final backgroundWithCutout = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          cutoutRect,
          Radius.circular(borderRadius),
        ),
      );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutoutRect, Radius.circular(borderRadius)),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return _ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      borderRadius: borderRadius,
      cutoutSize: cutoutSize,
    );
  }
}
