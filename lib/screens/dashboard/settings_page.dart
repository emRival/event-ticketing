import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:event_ticketing/network/get_ticket_services.dart';
import 'package:event_ticketing/provider/data_qr_provider.dart';
import 'package:event_ticketing/screens/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

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
  Color statusMessageColor = Colors.black87;
  Color statusPostMessageColor = Colors.black87;

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
      statusMessageColor = Colors.black87;
    });
    try {
      await GetTicketServices().refreshTickets(email: _emailController.text);
      setState(() {
        statusMessage = "Data berhasil diperbarui!";
        statusMessageColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        statusMessage = "Gagal memperbarui data: $e";
        statusMessageColor = Colors.red;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _postData() async {
    setState(() {
      isPosting = true;
      statusPostMessage = "Mengirim data ke API...";
      statusPostMessageColor = Colors.black87;
    });
    try {
      var response = await GetTicketServices().postTickets(
        email: _emailController.text,
      );
      setState(() {
        statusPostMessage = response['message'] ?? "Berhasil mengirim data";
        statusPostMessageColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        statusPostMessage = "Gagal mengirim data: $e";
        statusPostMessageColor = Colors.red;
      });
    } finally {
      setState(() => isPosting = false);
    }
  }

  Future<void> _logout() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Pastikan data sudah di-posting sebelum logout. Apakah ingin keluar sekarang?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              _showRefreshDialog();
            },
            child: Text('Perbarui Data', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              await Hive.box('settings').clear();
              var ticketsBox = await Hive.openBox<HiveGetTicketingResponse>('tickets');
              await ticketsBox.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.redAccent)),
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
        title: Text('Konfirmasi Perbarui', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
            child: Text('Perbarui', style: GoogleFonts.poppins(color: Colors.green)),
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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Pengaturan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Consumer<DataQrProvider>(
              builder: (context, provider, _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(
                    'Unredeemed',
                    provider.getQrDataListNotRedeemed.length.toString(),
                    Icons.cancel_outlined,
                    Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Redeemed',
                    provider.getQrDataListRedeemed.length.toString(),
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Sent',
                    provider.totalIssend.toString(),
                    Icons.cloud_circle_outlined,
                    theme.primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Akun', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _buildReadOnlyField('Email', _emailController, Icons.email),
                    const SizedBox(height: 16),
                    _buildReadOnlyField('Last Sync', _lastSyncController, Icons.sync),
                    const SizedBox(height: 16),
                    _buildReadOnlyField('Last Post', _lastPostController, Icons.cloud_upload),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: statusMessageColor),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Re-Generate Data',
              _showRefreshDialog,
              isLoading: isLoading,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              statusPostMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: statusPostMessageColor),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Post Data To API',
              _postData,
              isLoading: isPosting,
              color: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                count,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.poppins()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {bool isLoading = false, required Color color}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
      ),
    );
  }
}
