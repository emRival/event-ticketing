import 'dart:convert';
import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class GetTicketServices {
  final String baseUrl = 'https://apiwisudaidn.vercel.app/api';

  // Fungsi untuk mengambil data dari Hive (jika tersedia) atau API
  Future<List<HiveGetTicketingResponse>> getTickets({
    required String email,
  }) async {
    var box = await Hive.openBox<HiveGetTicketingResponse>('tickets');

    // Jika data sudah ada di Hive, langsung gunakan
    if (box.isNotEmpty) {
      return box.values.toList();
    }

    // Jika tidak ada data, panggil API
    return await refreshTickets(email: email);
  }

  // Fungsi untuk memperbarui data dari API dan menyimpannya ke Hive
  Future<List<HiveGetTicketingResponse>> refreshTickets({
    required String email,
  }) async {
    var box = await Hive.openBox<HiveGetTicketingResponse>('tickets');

    final Uri url = Uri.parse('$baseUrl?email=$email');

    try {
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          List<HiveGetTicketingResponse> tickets =
              decodedData
                  .map((json) => HiveGetTicketingResponse.fromJson(json))
                  .toList();

          // Hapus data lama dan simpan data baru
          await box.clear();
          for (var ticket in tickets) {
            await box.add(ticket);
          }

          Hive.box('settings').put(
            'lastSync',
            DateFormat('dd-MM-yyyy, hh:mm a').format(DateTime.now()),
          );

          return tickets;
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception(
          'Failed to fetch ticket data. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to refresh ticket data Gagal Konek ke server:  $e',
      );
    }
  }

  Future<Map<String, dynamic>> postTickets({required String email}) async {
    final Uri url = Uri.parse(baseUrl);

    var box = await Hive.openBox<HiveGetTicketingResponse>('tickets');
    List<Map<String, dynamic>> ticketsData =
        box.values
            .where(
              (ticket) => ticket.status == true && ticket.issend == false,
            ) // Filter hanya yang status = true dan issend = false
            .map((ticket) => ticket.toJson())
            .toList(); // Convert data ke JSON

    try {
      // Jika tidak ada data yang akan dikirim
      if (ticketsData.isEmpty) {
        return {"message": "Belum ada data yang dikirim", "success": false};
      }

      // Membuat payload JSON sesuai format yang diharapkan
      final Map<String, dynamic> payload = {
        "email": email,
        "data": ticketsData,
      };

      // Mengirim data ke server menggunakan HTTP POST
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Set header untuk JSON
        },
        body: jsonEncode(payload), // Encode payload ke JSON
      );

      // Cek status code response
      if (response.statusCode == 200) {
        // Parse response body ke Map
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ambil daftar ID tiket yang berhasil diupdate dari respons API
        final List<String> updatedTicketIds = List<String>.from(
          responseData['updated'],
        );

        // Update issend menjadi true untuk tiket yang berhasil dikirim
        for (var ticket in box.values) {
          if (updatedTicketIds.contains(ticket.id)) {
            ticket.issend = true; // Update issend menjadi true
            ticket.save(); // Simpan perubahan ke Hive
          }
        }

        // Tambahkan pesan jumlah data yang berhasil dikirim
        responseData['message'] =
            '${updatedTicketIds.length} data berhasil dikirim';
        return responseData; // Kembalikan respons JSON
      } else if (response.statusCode == 302) {
        // Tangani redirect
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final Uri redirectUri = Uri.parse(redirectUrl);

          // Coba kirim ulang dengan GET
          final http.Response redirectResponse = await http.get(
            redirectUri,
            headers: {'Content-Type': 'application/json'},
          );

          if (redirectResponse.statusCode == 200) {
            final Map<String, dynamic> responseData = jsonDecode(
              redirectResponse.body,
            );

            // Ambil daftar ID tiket yang berhasil diupdate dari respons API
            final List<String> updatedTicketIds = List<String>.from(
              responseData['updated'],
            );

            // Update issend menjadi true untuk tiket yang berhasil dikirim
            for (var ticket in box.values) {
              if (updatedTicketIds.contains(ticket.id)) {
                ticket.issend = true; // Update issend menjadi true
                ticket.save(); // Simpan perubahan ke Hive
              }
            }

            // Tambahkan pesan jumlah data yang berhasil dikirim
            responseData['message'] =
                '${updatedTicketIds.length} data berhasil dikirim';

            Hive.box('settings').put(
              'lastDataPost',
              DateFormat('dd-MM-yyyy, hh:mm a').format(DateTime.now()),
            );
            return responseData; // Kembalikan respons JSON
          } else {
            throw Exception(
              'Failed to post tickets after redirect. Status Code: ${redirectResponse.statusCode}',
            );
          }
        } else {
          throw Exception('Redirect URL not found in response headers');
        }
      } else {
        throw Exception(
          'Failed to post tickets. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to post tickets: $e');
    }
  }
}
