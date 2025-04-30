import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:event_ticketing/model/hive_get_ticketing_response.dart';
import 'package:intl/intl.dart';

class DataQrProvider with ChangeNotifier {
  late Box<HiveGetTicketingResponse> _qrDataBox;
  final Completer<void> initCompleter =
      Completer<void>(); // Untuk menunggu inisialisasi selesai

  DataQrProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _qrDataBox = await Hive.openBox<HiveGetTicketingResponse>('tickets');
    initCompleter.complete(); // Tandai bahwa inisialisasi selesai
    notifyListeners();
  }

  String _searchQuery = '';
  bool _showRegistered = true;
  bool _showRedeemed = false;
  ScannedData? scannedData;
  String scanStatus = 'Scan a QR Code';
  bool showRedeemButton = false;

  // Getters
  bool get getShowRegistered => _showRegistered;
  bool get getShowRedeemed => _showRedeemed;
  String get searchQuery => _searchQuery;
  List<HiveGetTicketingResponse> get qrDataList => _qrDataBox.values.toList();

  // total unredeemed
  int get totalUnredeemed =>
      qrDataList.where((qr) => !qr.status).toList().length;

  // total redeemed
  int get totalRedeemed => qrDataList.where((qr) => qr.status).toList().length;

  // total issend
  int get totalIssend =>
      qrDataList.where((qr) => qr.issend == true).toList().length;

  // Setters
  set setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  set setShowRegistered(bool value) {
    _showRegistered = value;
    notifyListeners();
  }

  set setShowRedeemed(bool value) {
    _showRedeemed = value;
    notifyListeners();
  }

  // Filtered Lists
  List<HiveGetTicketingResponse> get getQrDataListNotRedeemed =>
      qrDataList
          .where((qr) => !qr.status && qr.nama!.contains(_searchQuery))
          .toList();

  List<HiveGetTicketingResponse> get getQrDataListRedeemed =>
      qrDataList
          .where((qr) => qr.status && qr.nama!.contains(_searchQuery))
          .toList();

  // Menambahkan data ke Hive
  Future<void> addQrData(HiveGetTicketingResponse qrData) async {
    await _qrDataBox.put(qrData.id, qrData);
    notifyListeners();
  }

  // Memperbarui data di Hive
  Future<void> updateQrData(HiveGetTicketingResponse qrData) async {
    await _qrDataBox.put(qrData.id, qrData);
    notifyListeners();
  }

  // Menghapus data dari Hive
  Future<void> deleteQrData(String id) async {
    await _qrDataBox.delete(id);
    notifyListeners();
  }

  // Memproses hasil scan QR Code
  void processScannedQR(String code) {
    final foundQR = qrDataList.firstWhere(
      (qr) => qr.id == code,
      orElse: () => HiveGetTicketingResponse(),
    );

    if (foundQR.status) {
      scanStatus = 'QR Code has already been redeemed';
      showRedeemButton = false;
      scannedData = ScannedData(
        id: code,
        nokursi: foundQR.nokursi,
        nama: foundQR.nama ?? 'Nama',
        cabang: foundQR.cabang ?? 'Cabang',
        jam: foundQR.jamKedatangan?.split(' ')[1] ?? '-',
      );
    } else if (foundQR.id == code) {
      scanStatus = 'QR Code Valid and Ready to Use';
      showRedeemButton = true;
      scannedData = ScannedData(
        id: code,
        nokursi: foundQR.nokursi,
        nama: foundQR.nama ?? 'Nama',
        cabang: foundQR.cabang ?? 'Cabang',
        jam: '-',
      );
    } else {
      scanStatus = 'QR Code Invalid';
      showRedeemButton = false;
      scannedData = null;
    }
    notifyListeners();
  }

  void clearScannedData() {
    scannedData = null;
    scanStatus = 'Scan a QR Code';
    showRedeemButton = false;
    notifyListeners();
  }

  // Menebus QR Code yang sudah dipindai
  Future<void> redeemScannedQR(String code) async {
    final foundQR = qrDataList.firstWhere(
      (qr) => qr.id == code,
      orElse: () => HiveGetTicketingResponse(),
    );
    foundQR.status = true;
    foundQR.jamKedatangan = DateFormat(
      'dd-MM-yyyy, hh:mm a',
    ).format(DateTime.now());
    await foundQR.save();
    scanStatus = 'QR Code Redeemed Successfully!';
    showRedeemButton = false;
    notifyListeners();
  }

  //unreedeem
  Future<void> unredeemScannedQR(String code) async {
    final foundQR = qrDataList.firstWhere(
      (qr) => qr.id == code,
      orElse: () => HiveGetTicketingResponse(),
    );
    foundQR.status = false;
    foundQR.issend = false;
    foundQR.jamKedatangan = '';
    await foundQR.save();
    scanStatus = 'QR Code Unredeemed Successfully!';
    showRedeemButton = false;
    notifyListeners();
  }
}

class ScannedData {
  final String id;
  final String? nokursi;
  final String nama;
  final String cabang;
  final String? jam;

  ScannedData({
    required this.id,
    this.nokursi,
    required this.nama,
    required this.cabang,
    this.jam,
  });
}
