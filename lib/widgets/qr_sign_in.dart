import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/auth_service.dart';

class QRSignInWidget extends StatefulWidget {
  final AuthService authService;

  const QRSignInWidget({
    super.key,
    required this.authService,
  });

  @override
  State<QRSignInWidget> createState() => _QRSignInWidgetState();
}

class _QRSignInWidgetState extends State<QRSignInWidget> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isScanning = !_isScanning;
            });
          },
          child: Text(_isScanning ? 'Cancel Scan' : 'Scan QR Code'),
        ),
        const SizedBox(height: 20),
        if (_isScanning)
          SizedBox(
            height: 300,
            width: 300,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _handleQRCode(barcode.rawValue!);
                  }
                }
              },
            ),
          ),
      ],
    );
  }

  void _handleQRCode(String code) async {
    try {
      // For now, just try Google Sign-In when a QR code is scanned
      await widget.authService.signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully signed in with Google')),
        );
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in with QR code: $e')),
        );
      }
    }
  }
}
