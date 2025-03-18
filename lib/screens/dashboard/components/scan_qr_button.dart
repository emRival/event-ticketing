import 'package:flutter/material.dart';

class ScanQRButton extends StatelessWidget {
  const ScanQRButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      margin: EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_scanner, size: 80.0, color: Colors.white),
          SizedBox(height: 10.0),
          Text(
            'Scan QR Code',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}