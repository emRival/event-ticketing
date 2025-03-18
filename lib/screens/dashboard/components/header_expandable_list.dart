import 'package:flutter/material.dart';

class HeaderExpandableList extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onTap;

  const HeaderExpandableList({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}