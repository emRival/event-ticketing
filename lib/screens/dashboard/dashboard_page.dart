import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:event_ticketing/network/get_ticket_services.dart';
import 'package:event_ticketing/provider/data_qr_provider.dart';
import 'package:event_ticketing/screens/dashboard/components/header_expandable_list.dart';
import 'package:event_ticketing/screens/dashboard/components/qr_list.dart';
import 'package:event_ticketing/screens/dashboard/components/scan_qr_button.dart';
import 'package:event_ticketing/screens/dashboard/components/search_bar.dart';
import 'package:event_ticketing/screens/dashboard/settings_page.dart';
import 'package:event_ticketing/screens/scanner/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  final String email;
  const DashboardPage({super.key, required this.email});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<HiveGetTicketingResponse>> futureTickets;

  @override
  void initState() {
    super.initState();
    fetchTickets();
    WidgetsBinding.instance.endOfFrame.then((_) {
      setState(() {});
    });
  }

  void fetchTickets() {
    setState(() {
      futureTickets = GetTicketServices().getTickets(email: widget.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HiveGetTicketingResponse>>(
        future: futureTickets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_outlined, size: 100),
                    const SizedBox(height: 20),
                    Text(
                      "Terjadi kesalahan: ${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchTickets,
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data tiket"));
          }
          return FutureBuilder(
            future:
                context
                    .read<DataQrProvider>()
                    .initCompleter
                    .future, // Menunggu inisialisasi Hive
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                ); // Menampilkan loading saat Hive belum siap
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<DataQrProvider>(
                  builder:
                      (context, provider, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScannerPage(),
                                  ),
                                );
                              },
                              child: ScanQRButton(),
                            ),
                          ),
                          MySearchBar(
                            onSearch: (query) {
                              provider.setSearchQuery = query;
                            },
                          ),
                          HeaderExpandableList(
                            title: 'Unredeem QR Codes',
                            isExpanded: provider.getShowRegistered,
                            onTap: () {
                              if (provider.getShowRedeemed) {
                                provider.setShowRedeemed = false;
                              }
                              provider.setShowRegistered =
                                  !provider.getShowRegistered;
                            },
                          ),
                          if (provider.getShowRegistered)
                            Expanded(
                              child: QRList(
                                qrList: provider.getQrDataListNotRedeemed,

                                onEdit: (id) {
                                  provider.redeemScannedQR(id);
                                },
                              ),
                            ),
                          HeaderExpandableList(
                            title: 'Redeemed QR Codes',
                            isExpanded: provider.getShowRedeemed,
                            onTap: () {
                              if (provider.getShowRegistered) {
                                provider.setShowRegistered = false;
                              }
                              provider.setShowRedeemed =
                                  !provider.getShowRedeemed;
                            },
                          ),
                          if (provider.getShowRedeemed)
                            Expanded(
                              child: QRList(
                                qrList: provider.getQrDataListRedeemed,
                                onEdit: (id) {
                                  provider.unredeemScannedQR(id);
                                },
                              ),
                            ),
                          const SizedBox(height: 5),
                        ],
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
