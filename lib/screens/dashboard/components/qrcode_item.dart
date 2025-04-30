import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:event_ticketing/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QRListItem extends StatefulWidget {
  final HiveGetTicketingResponse qr;
  final VoidCallback? onShare;

  const QRListItem({super.key, required this.qr, this.onShare});

  @override
  State<QRListItem> createState() => _QRListItemState();
}

class _QRListItemState extends State<QRListItem> {
  final GlobalKey _qrKeyForShare = GlobalKey(); // Untuk share

  Future<void> _shareQrImage() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      RenderRepaintBoundary boundary =
          _qrKeyForShare.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/${widget.qr.id}.png';
      await File(path).writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(path)],
        text: '''
🧾 *Backup QR Code Peserta Wisuda*

📛 Nama   : ${widget.qr.nama ?? '-'}
🏫 Cabang : ${widget.qr.cabang ?? '-'}
🏷️ Kelas  : ${widget.qr.kelas ?? '-'}

📌 Simpan gambar ini sebagai cadangan untuk keperluan verifikasi saat hari H wisuda. Pastikan QR tetap bisa dipindai dengan jelas.

Terima kasih 🙏
''',
      );

      widget.onShare?.call();
    } catch (e) {
      debugPrint('Error sharing QR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _shareQrImage,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: QrImageView(
              data: widget.qr.id ?? '-',
              version: QrVersions.auto,
              size: 160,
              gapless: false,
            ),
          ),
        ),

        // Untuk keperluan share
        Positioned(
          left: -9999,
          top: -9999,
          child: RepaintBoundary(
            key: _qrKeyForShare,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: widget.qr.id ?? '-',
                    version: QrVersions.auto,
                    size: 180,
                    gapless: false,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.qr.nama ?? widget.qr.id ?? '-',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildBadge(
                    'Cabang: ${widget.qr.cabang ?? '-'}',
                    getCabangColor(widget.qr.cabang),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildBadge(String label, Color color) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 200),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      border: Border.all(color: color, width: 1),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Text(
      label,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    ),
  );
}
