import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:event_ticketing/network/get_ticket_services.dart';
import 'package:event_ticketing/provider/data_qr_provider.dart';
import 'package:event_ticketing/screens/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _emailController = TextEditingController();
  final _lastSyncController = TextEditingController();
  final _lastPostController = TextEditingController();

  bool isLoading = false;
  bool isPosting = false;
  String statusMessage = "Tekan tombol di bawah untuk memperbarui data.";
  String statusPostMessage = "Tekan tombol di bawah untuk mengirim data.";
  Color statusMessageColor = Colors.black54;
  Color statusPostMessageColor = Colors.black54;

  late String email;
  late String lastSync;
  late String lastDataPost;

  @override
  void initState() {
    super.initState();
    var box = Hive.box('settings');
    email = box.get('email', defaultValue: "Belum ada data");
    lastSync = box.get('lastSync', defaultValue: "Belum ada data");
    lastDataPost = box.get('lastDataPost', defaultValue: "Belum ada data");
    _emailController.text = email;
    _lastSyncController.text = lastSync;
    _lastPostController.text = lastDataPost;
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      statusMessage = "Mengambil data terbaru...";
      statusMessageColor = Colors.black54;
    });
    try {
      await GetTicketServices().refreshTickets(email: _emailController.text);
      setState(() {
        statusMessage = "Data berhasil diperbarui!";
        statusMessageColor = const Color(0xFF16A34A);
      });
    } catch (e) {
      setState(() {
        statusMessage = "Gagal memperbarui data: $e";
        statusMessageColor = const Color(0xFFDC2626);
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _postData() async {
    setState(() {
      isPosting = true;
      statusPostMessage = "Mengirim data ke API...";
      statusPostMessageColor = Colors.black54;
    });
    try {
      var response = await GetTicketServices().postTickets(
        email: _emailController.text,
      );
      setState(() {
        statusPostMessage = response['message'] ?? "Berhasil mengirim data";
        statusPostMessageColor = const Color(0xFF16A34A);
      });
    } catch (e) {
      setState(() {
        statusPostMessage = "Gagal mengirim data: $e";
        statusPostMessageColor = const Color(0xFFDC2626);
      });
    } finally {
      setState(() => isPosting = false);
    }
  }

  Future<void> _logout() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Pastikan data sudah di-posting sebelum logout. Apakah ingin keluar sekarang?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showRefreshDialog();
            },
            child: Text('Perbarui Data', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              await Hive.box('settings').clear();
              var ticketsBox =
                  await Hive.openBox<HiveGetTicketingResponse>('tickets');
              await ticketsBox.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: const Color(0xFFDC2626)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showRefreshDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Perbarui',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Data lama akan dihapus. Pastikan data sudah di-posting sebelumnya.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _postData();
            },
            child: Text('Post Data', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _refreshData();
            },
            child: Text(
              'Perbarui',
              style:
                  GoogleFonts.poppins(color: const Color(0xFF16A34A)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            color: const Color(0xFFDC2626),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stats Row
                Consumer<DataQrProvider>(
                  builder: (context, provider, _) => Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Unredeemed',
                          provider.getQrDataListNotRedeemed.length.toString(),
                          Icons.cancel_outlined,
                          const Color(0xFFDC2626),
                          const Color(0xFFFEF2F2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Redeemed',
                          provider.getQrDataListRedeemed.length.toString(),
                          Icons.check_circle_outline,
                          const Color(0xFF16A34A),
                          const Color(0xFFF0FDF4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Sent',
                          provider.totalIssend.toString(),
                          Icons.cloud_done_outlined,
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.06),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Akun',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Email', _emailController.text, Icons.email_outlined),
                        const SizedBox(height: 12),
                        _buildInfoRow('Last Sync', _lastSyncController.text, Icons.sync),
                        const SizedBox(height: 12),
                        _buildInfoRow('Last Post', _lastPostController.text, Icons.cloud_upload_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sync Section
                _buildActionSection(
                  title: 'Sinkronisasi Data',
                  icon: Icons.sync,
                  statusMessage: statusMessage,
                  statusColor: statusMessageColor,
                  buttonText: 'Re-Generate Data',
                  buttonColor: const Color(0xFF16A34A),
                  isLoading: isLoading,
                  onPressed: _showRefreshDialog,
                ),
                const SizedBox(height: 20),

                // Post Section
                _buildActionSection(
                  title: 'Kirim Data',
                  icon: Icons.cloud_upload_outlined,
                  statusMessage: statusPostMessage,
                  statusColor: statusPostMessageColor,
                  buttonText: 'Post Data To API',
                  buttonColor: colorScheme.primary,
                  isLoading: isPosting,
                  onPressed: _postData,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String count,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection({
    required String title,
    required IconData icon,
    required String statusMessage,
    required Color statusColor,
    required String buttonText,
    required Color buttonColor,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: buttonColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              statusMessage,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        buttonText,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
