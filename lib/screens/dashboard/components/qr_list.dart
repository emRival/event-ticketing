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
    if (qrList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak ada data',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: qrList.length,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (context, index) {
        var qr = qrList[index];
        return Dismissible(
          key: Key(qr.id ?? index.toString()),
          direction: qr.status
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
              builder: (context) => AlertDialog(
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
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showDetails(context, qr),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: qr.status
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code_rounded,
                        color: qr.status
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF2563EB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            qr.nama ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildBadge(
                                qr.nokursi ?? '-',
                                Icons.event_seat_outlined,
                                const Color(0xFF2563EB),
                              ),
                              _buildBadge(
                                qr.cabang ?? '-',
                                Icons.location_on_outlined,
                                getCabangColor(qr.cabang),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
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
    final color = status ? const Color(0xFFF59E0B) : const Color(0xFF16A34A);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSecondary ? Icons.undo_rounded : Icons.check_rounded,
            color: Colors.white,
            size: 24,
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

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, HiveGetTicketingResponse qr) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '🎟 Detail Tiket',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
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
                        _infoItem(
                            'Jam Kedatangan', qr.jamKedatangan ?? '-'),
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
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: QRListItem(qr: qr),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(
                                qr.status
                                    ? Icons.undo_rounded
                                    : Icons.check_circle_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: qr.status
                                    ? Colors.grey.shade700
                                    : colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () =>
                                  _confirmAction(context, qr),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  qr.status ? 'Unredeem' : 'Redeem',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              child: Text(
                                'Tutup',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                  tooltip: 'Tutup',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String? value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color ?? const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(8),
              border: color == null
                  ? Border.all(color: Colors.grey.shade200)
                  : null,
            ),
            child: Text(
              value ?? '-',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: color != null ? Colors.white : const Color(0xFF111827),
                fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, HiveGetTicketingResponse qr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
