import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:event_ticketing/screens/dashboard/components/qrcode_item.dart';
import 'package:event_ticketing/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class QRList extends StatelessWidget {
  final List<HiveGetTicketingResponse> qrList;
  final Function(String)? onEdit;

  const QRList({super.key, required this.qrList, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: qrList.length,
      itemBuilder: (context, index) {
        var qr = qrList[index];
        return Dismissible(
          key: Key(qr.id ?? index.toString()),
          direction:
              qr.status
                  ? DismissDirection.endToStart
                  : DismissDirection.startToEnd,
          background: _buildSwipeBackground(qr.status),
          secondaryBackground: _buildSwipeBackground(
            qr.status,
            isSecondary: true,
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: Text(
                      'Apakah Anda yakin ingin ${qr.status ? 'unredeem' : 'redeem'} tiket ini?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Ya'),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (direction) {
            if (onEdit != null && qr.id != null) {
              onEdit!(qr.id!);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tiket ${qr.nama ?? '-'} telah ${!qr.status ? 'unredeemed' : 'redeemed'}',
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 6,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => _showDetails(context, qr),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          qr.status
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                      child: Icon(
                        Icons.qr_code,
                        color: qr.status ? Colors.green : Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            qr.nama ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildBadge(
                                'No Kursi: ${qr.nokursi ?? '-'}',
                                Colors.blue,
                              ),
                              _buildBadge(
                                'Cabang: ${qr.cabang ?? '-'}',
                                getCabangColor(qr.cabang),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeBackground(bool status, {bool isSecondary = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              status
                  ? [Colors.orangeAccent, Colors.deepOrange]
                  : [Colors.greenAccent, Colors.green],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSecondary ? Icons.close : Icons.check,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            isSecondary ? 'Unredeem' : 'Redeem',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, HiveGetTicketingResponse qr) {
    showDialog(
      context: context,
      barrierDismissible: false, // agar hanya bisa ditutup dari tombol
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            '🎟 Detail Tiket',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _infoItem('No Kursi', qr.nokursi),
                        _infoItem('Nama', qr.nama),
                        _infoItem('Kelas', qr.kelas),
                        _infoItem('Cabang', qr.cabang),
                        _infoItem(
                          'Status',
                          qr.status ? 'Redeemed' : 'Unredeemed',
                        ),
                        if (qr.status)
                          _infoItem('Jam Kedatangan', qr.jamKedatangan ?? '-'),
                        _infoItem(
                          'Is Send',
                          qr.issend == true ? 'Ya' : 'Tidak',
                        ),
                        _infoItem(
                          'Warna Gelang',
                          '',
                          getCabangColor(qr.cabang),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 160,
                            height: 160,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                         child: QRListItem(qr: qr),

                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(
                                qr.status ? Icons.undo : Icons.check_circle,
                                size: 18,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    qr.status
                                        ? Colors.grey[700]
                                        : Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _confirmAction(context, qr),
                              label: Text(
                                qr.status ? 'Unredeem' : 'Redeem',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Tutup',
                                style: GoogleFonts.poppins(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ⛔️ Tombol X di pojok kanan atas
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                      tooltip: 'Tutup',
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _infoItem(String label, String? value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color:Colors.grey[800],
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value ?? '-',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, HiveGetTicketingResponse qr) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Konfirmasi'),
            content: Text(
              'Apakah Anda yakin ingin ${qr.status ? 'unredeem' : 'redeem'} tiket ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  if (onEdit != null && qr.id != null) onEdit!(qr.id!);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Ya'),
              ),
            ],
          ),
    );
  }
}
