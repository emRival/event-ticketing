import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  const MySearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearch,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Cari QR Code...',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
