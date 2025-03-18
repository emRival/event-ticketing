import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const MySearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search QR Codes',
          border: OutlineInputBorder(),
        ),
        onChanged: onSearch,
      ),
    );
  }
}