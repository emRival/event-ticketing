import 'package:hive/hive.dart';

part 'hive_get_ticketing_response.g.dart';

@HiveType(typeId: 3) // Pastikan ID unik untuk setiap model Hive
class HiveGetTicketingResponse extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? cabang;

  @HiveField(2)
  String? nama;

  @HiveField(3)
  String? kelas;

  @HiveField(4)
  String? panitia;

  @HiveField(5)
  bool status; // Tidak nullable untuk menghindari error

  @HiveField(6)
  bool? issend;

  @HiveField(7)
  String? jamKedatangan;

  HiveGetTicketingResponse({
    this.id,
    this.cabang,
    this.nama,
    this.kelas,
    this.panitia,
    this.status = false, // Default false jika null
    this.issend = false, // Default false jika null
    this.jamKedatangan,
  });

  factory HiveGetTicketingResponse.fromJson(Map<String, dynamic> json) {
    return HiveGetTicketingResponse(
      id: json['id'],
      cabang: json['cabang'],
      nama: json['nama'],
      kelas: json['kelas'],
      panitia: json['panitia'],
      status:
          json['status'] is bool
              ? json['status']
              : (json['status'].toString().trim().isEmpty
                  ? false
                  : json['status']),
      // Pastikan boolean tidak null
      issend: json['issend'] ?? false,
      jamKedatangan: json['jam_kedatangan'],
    );
  }

  static List<HiveGetTicketingResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => HiveGetTicketingResponse.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cabang': cabang,
      'nama': nama,
      'kelas': kelas,
      'panitia': panitia,
      'status': status,
      'issend': issend,
      'jam_kedatangan': jamKedatangan,
    };
  }
}
