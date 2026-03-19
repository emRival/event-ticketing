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
import 'package:google_fonts/google_fonts.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<HiveGetTicketingResponse>>(
        future: futureTickets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_outlined,
                        size: 72,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Terjadi Kesalahan",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: fetchTickets,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Coba Lagi"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tidak ada data tiket",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return FutureBuilder(
            future: context.read<DataQrProvider>().initCompleter.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                );
              }
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Consumer<DataQrProvider>(
                      builder: (context, provider, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Scan QR Button
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScannerPage(email: widget.email),
                                  ),
                                );
                              },
                              child: const ScanQRButton(),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Search Bar
                          MySearchBar(
                            onSearch: (query) {
                              provider.setSearchQuery = query;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Unredeem section
                          HeaderExpandableList(
                            title: 'Unredeem QR Codes',
                            count: provider.getQrDataListNotRedeemed.length,
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

                          // Redeemed section
                          HeaderExpandableList(
                            title: 'Redeemed QR Codes',
                            count: provider.getQrDataListRedeemed.length,
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
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
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
