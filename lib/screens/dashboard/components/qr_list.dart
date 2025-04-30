import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
          key: Key(qr.id!), // Key unik untuk setiap item
          direction:
              qr.status
                  ? DismissDirection
                      .endToStart // Hanya swipe ke kiri untuk unredeem
                  : DismissDirection
                      .startToEnd, // Hanya swipe ke kanan untuk redeem
          background: _buildSwipeBackground(qr.status),
          secondaryBackground: _buildSwipeBackground(
            qr.status,
            isSecondary: true,
          ),
          confirmDismiss: (direction) async {
            // Konfirmasi sebelum melakukan redeem/unredeem
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
            if (onEdit != null) {
              onEdit!(qr.id!); // Panggil fungsi onEdit untuk update status
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tiket ${qr.nama} telah ${!qr.status ? 'unredeemed' : 'redeemed'}',
                ),
                duration: const Duration(seconds: 2),
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
                            qr.nama!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No Kursi: ${qr.nokursi}\nCabang: ${qr.cabang}',
                            style: const TextStyle(fontSize: 14),
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

  // Widget untuk latar belakang swipe
  Widget _buildSwipeBackground(bool status, {bool isSecondary = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: status ? Colors.orange : Colors.green,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isSecondary ? Icons.close : Icons.check,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  void _showDetails(BuildContext context, HiveGetTicketingResponse qr) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Center(
              child: Text(
                'Detail Tiket',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailItem('No Kursi', qr.nokursi),
                  _detailItem('Nama', qr.nama),
                  _detailItem('Kelas', qr.kelas),
                  _detailItem('Cabang', qr.cabang),
                  _statusItem(qr.status),
                  if (qr.status)
                    _detailItem(
                      'Jam Kedatangan',
                      qr.jamKedatangan != null
                          ? (qr.jamKedatangan!.split(' ').length > 1
                              ? qr.jamKedatangan!.split(' ')[1]
                              : '-')
                          : '-',
                    ),

                  _detailItem('Is Send', qr.issend.toString()),
                  const SizedBox(height: 15),
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: qr.id!,
                        version: QrVersions.auto,
                        size: 160.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => _confirmAction(context, qr),
                    child: Text(
                      qr.status ? 'Unredeem' : 'Redeem',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _detailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _statusItem(bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            const TextSpan(
              text: 'Status: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: status ? 'Redeemed' : 'Unredeemed',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: status ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
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
                  if (onEdit != null) {
                    onEdit!(qr.id!);
                  }
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
