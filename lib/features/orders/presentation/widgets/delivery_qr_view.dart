import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DeliveryQrView extends StatelessWidget {
  const DeliveryQrView({
    super.key,
    required this.orderId,
    required this.deliveryToken,
    this.size = 220.0,
  });

  final String orderId;
  final String deliveryToken;
  final double size;

  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({'orderId': orderId, 'token': deliveryToken});

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          child: QrImageView(
            data: payload,
            version: QrVersions.auto,
            size: size,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'Token: $deliveryToken',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}
