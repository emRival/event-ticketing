import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:event_ticketing/network/get_ticket_services.dart';
import 'package:event_ticketing/screens/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _lastSyncController = TextEditingController();
  final TextEditingController _lastDataPostController = TextEditingController();

  bool isLoading = false;
  bool isPosting = false;
  String statusMessage = "Tekan tombol di bawah untuk memperbarui data.";
  String statusPostMessage = "Tekan tombol di bawah untuk mengirim data.";
  Color statusMessageColor = Colors.black;
  Color statusPostMessageColor = Colors.black;
  var lastSync = Hive.box(
    'settings',
  ).get('lastSync', defaultValue: "Belum ada data");
  var email = Hive.box('settings').get('email', defaultValue: "Belum ada data");
  var lastDataPost = Hive.box(
    'settings',
  ).get('lastDataPost', defaultValue: "Belum ada data");

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _emailController.text = email;
    _lastSyncController.text = lastSync;
    _lastDataPostController.text =
        lastDataPost; // Ganti dengan data yang sesuai
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      statusMessage = "Mengambil data terbaru...";
      statusMessageColor = Colors.black;
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
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _postData() async {
    setState(() {
      isPosting = true;
      statusPostMessage = "Mengirim data ke API...";
      statusPostMessageColor = Colors.black;
    });

    try {
      var response = await GetTicketServices().postTickets(
        email: _emailController.text,
      );
      setState(() {
        statusPostMessage = response['message'];
        statusPostMessageColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        statusPostMessage = "Gagal mengirim data: $e";
        statusPostMessageColor = Colors.red;
      });
    }

    setState(() {
      isPosting = false;
    });
  }

  Future<void> _logout() async {
    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                icon: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Konfirmasi Logout'),
                content: Text(
                  'Apakah Anda yakin ingin logout? Pastikan data telah ter-posting.',
                  textAlign: TextAlign.start,
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            isPosting = true;
                          });
                          await _postData();
                          setState(() {
                            isPosting = false;
                          });
                        },
                        child:
                            isPosting
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.blueAccent,
                                  ),
                                )
                                : const Text('Post Data'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Hapus semua data di Hive
                          await Hive.box('settings').clear();
                          var ticketsBox =
                              await Hive.openBox<HiveGetTicketingResponse>(
                                'tickets',
                              );
                          await ticketsBox.clear();

                          // Navigasi ke halaman login
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: const Text('Logout'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Pengaturan"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastSyncController,
                decoration: InputDecoration(
                  enabled: false,
                  labelText: 'Last Data Sync',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(Icons.timeline_rounded),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastDataPostController,
                decoration: InputDecoration(
                  enabled: false,
                  labelText: 'Last Data Post',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(Icons.cloud_upload),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: statusMessageColor),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                    ),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  icon: const Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                  ),
                                  title: const Text('Konfirmasi'),
                                  content: Text(
                                    'Apakah Anda yakin ingin memperbarui data? Data yang sudah ada akan dihapus.\n\nPastikan anda telah post data terlebih dahulu.',
                                    textAlign: TextAlign.start,
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            await _postData();
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                          child:
                                              isLoading
                                                  ? SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color:
                                                              Colors.blueAccent,
                                                        ),
                                                  )
                                                  : const Text('Post Data'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _refreshData();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Perbarui Data'),
                                        ),

                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: const Text('Batal'),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                      );
                    },
                    child: Text(
                      "Re-Generate Data",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              const SizedBox(height: 20),
              Text(
                statusPostMessage,
                style: TextStyle(color: statusPostMessageColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              isPosting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade700,
                    ),
                    onPressed: _postData,
                    child: Text(
                      "Post Data To API",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
