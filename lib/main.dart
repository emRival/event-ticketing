import 'package:device_preview/device_preview.dart';
import 'package:event_ticketing/provider/data_qr_provider.dart';
import 'package:event_ticketing/screens/auth/login_page.dart';
import 'package:event_ticketing/screens/dashboard/dashboard_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:event_ticketing/model/hive_get_ticketing_response.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HiveGetTicketingResponseAdapter());
  await Hive.openBox('settings'); // Buka box settings

  runApp(
    DevicePreview(
      isToolbarVisible:
          !(defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android),
      defaultDevice: Devices.ios.iPhone13ProMax,
      enabled:
          !(defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android),
      builder:
          (context) => ChangeNotifierProvider(
            create: (context) => DataQrProvider(),
            child: MainApp(),
          ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Future.wait([Hive.openBox('settings')]),
        // Pastikan box sudah terbuka
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var settingBox = Hive.box('settings');
            var email = settingBox.get("email", defaultValue: null);

            if (email != null && email.isNotEmpty) {
              // Jika email ada, arahkan ke dashboard
              return DashboardPage(
                email: email,
              ); // Ganti dengan halaman dashboard Anda
            } else {
              // Jika email kosong, arahkan ke halaman login
              return LoginPage();
            }
          } else {
            // Tampilkan loading indicator sambil menunggu
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}
