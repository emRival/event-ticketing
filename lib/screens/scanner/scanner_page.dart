import 'dart:async';

import 'package:event_ticketing/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:event_ticketing/provider/data_qr_provider.dart';

class ScannerPage extends StatefulWidget {
  final String email;
  const ScannerPage({super.key, required this.email});

  @override
  ScannerPageState createState() => ScannerPageState();
}

class ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
  );
  StreamSubscription<Object?>? _subscription;
  Timer? _clearDataTimer;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startScanner();
  }

  Future<void> _startScanner() async {
    _subscription = _controller.barcodes.listen(_handleBarcode);
    await _controller.start();
    if (mounted) {
      setState(() => _isStarted = true);
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        context.read<DataQrProvider>().processScannedQR(barcode.rawValue!);
        _resetClearDataTimer();
        break;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(_controller.stop());
        break;
      case AppLifecycleState.resumed:
        _subscription = _controller.barcodes.listen(_handleBarcode);
        unawaited(_controller.start());
        break;
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(_controller.stop());
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    _clearDataTimer?.cancel();
    _controller.dispose();
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
    _clearDataTimer?.cancel();
    _clearDataTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        context.read<DataQrProvider>().clearScannedData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrProvider = context.watch<DataQrProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan QR Code',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              widget.email,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Toggle torch
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color: colorScheme.primary,
                );
              },
            ),
            tooltip: 'Flash',
            onPressed: () => _controller.toggleTorch(),
          ),
          // Switch camera
          IconButton(
            icon: Icon(
              Icons.cameraswitch_rounded,
              color: colorScheme.primary,
            ),
            tooltip: 'Ganti Kamera',
            onPressed: () => _controller.switchCamera(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isWide
          ? _buildWideLayout(qrProvider, colorScheme)
          : _buildNarrowLayout(qrProvider, colorScheme),
    );
  }

  Widget _buildWideLayout(DataQrProvider qrProvider, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _buildScannerView(colorScheme),
        ),
        Expanded(
          flex: 4,
          child: _buildResultPanel(qrProvider, colorScheme),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
      DataQrProvider qrProvider, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _buildScannerView(colorScheme),
        ),
        Expanded(
          flex: 3,
          child: _buildResultPanel(qrProvider, colorScheme),
        ),
      ],
    );
  }

  Widget _buildScannerView(ColorScheme colorScheme) {
    return Stack(
      children: [
        MobileScanner(controller: _controller),
        // Overlay frame
        if (_isStarted)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.shortestSide * 0.55,
              height: MediaQuery.of(context).size.shortestSide * 0.55,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultPanel(DataQrProvider qrProvider, ColorScheme colorScheme) {
    final hasInvalid = qrProvider.scanStatus.contains('Invalid');
    final hasRedeemed = qrProvider.scanStatus.contains('redeemed');

    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    if (hasInvalid) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusIcon = Icons.error_outline;
    } else if (hasRedeemed) {
      statusColor = const Color(0xFFF59E0B);
      statusBg = const Color(0xFFFFFBEB);
      statusIcon = Icons.info_outline;
    } else {
      statusColor = const Color(0xFF16A34A);
      statusBg = const Color(0xFFF0FDF4);
      statusIcon = Icons.check_circle_outline;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (qrProvider.scannedData != null) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    color: statusBg,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            'No Kursi',
                            qrProvider.scannedData!.nokursi ?? '-',
                          ),
                          _buildDetailRow(
                            'Nama',
                            qrProvider.scannedData!.nama,
                          ),
                          _buildDetailRow(
                            'Cabang',
                            qrProvider.scannedData!.cabang,
                          ),
                          if (qrProvider.scannedData!.jam != null &&
                              qrProvider.scannedData!.jam!.isNotEmpty)
                            _buildDetailRow(
                              'Jam',
                              qrProvider.scannedData!.jam ?? '-',
                            ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: getCabangColor(
                                qrProvider.scannedData?.cabang,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Warna Gelang',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Status message
                if (qrProvider.scanStatus.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            qrProvider.scanStatus,
                            style: GoogleFonts.poppins(
                              color: statusColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Redeem Button
                if (qrProvider.showRedeemButton)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => qrProvider.redeemScannedQR(
                        qrProvider.scannedData!.id,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Redeem Now',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
