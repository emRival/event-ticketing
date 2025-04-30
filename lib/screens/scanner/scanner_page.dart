import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:event_ticketing/provider/data_qr_provider.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  ScannerPageState createState() => ScannerPageState();
}

class ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  Timer? _clearDataTimer; // Timer untuk menghapus data
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // ignore: deprecated_member_use
    controller.dispose();
    _clearDataTimer?.cancel(); // Hentikan timer jika ada
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    if (mounted) {
      context.read<DataQrProvider>().clearScannedData();
    }
    super.deactivate();
  }

  void _resetClearDataTimer() {
    _clearDataTimer?.cancel(); // Hentikan timer sebelumnya
    _clearDataTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        context.read<DataQrProvider>().clearScannedData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrProvider = context.watch<DataQrProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: (controller) {
                    this.controller = controller;
                    controller.scannedDataStream.listen((scanData) {
                      if (scanData.code != null) {
                        context.read<DataQrProvider>().processScannedQR(
                          scanData.code!,
                        );
                        _resetClearDataTimer();
                      }
                    });
                  },
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.blueAccent,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () async {
                      await controller.toggleFlash();
                      bool? flashStatus = await controller.getFlashStatus();
                      setState(() {
                        isFlashOn = flashStatus ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bagian tampilan hasil scan tetap sama
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (qrProvider.scannedData != null)
                      Card(
                        elevation: 5,
                        color:
                            qrProvider.scanStatus.contains('Invalid')
                                ? Colors.red
                                : (qrProvider.scanStatus.contains('redeemed')
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Kursi: ${qrProvider.scannedData!.nokursi}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nama: ${qrProvider.scannedData!.nama}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cabang: ${qrProvider.scannedData!.cabang}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (qrProvider.scannedData!.jam!.isNotEmpty)
                                const SizedBox(height: 8),
                              Text(
                                'Jam: ${qrProvider.scannedData!.jam}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (qrProvider.scanStatus.isNotEmpty)
                      const SizedBox(height: 10),
                    Text(
                      qrProvider.scanStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            qrProvider.scanStatus.contains('Invalid')
                                ? Colors.red
                                : (qrProvider.scanStatus.contains('redeemed')
                                    ? Colors.orange
                                    : Colors.green),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (qrProvider.showRedeemButton)
                      ElevatedButton.icon(
                        onPressed:
                            () => qrProvider.redeemScannedQR(
                              qrProvider.scannedData!.id,
                            ),
                        icon: const Icon(
                          Icons.cut_sharp,
                          size: 24,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Redeem Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
