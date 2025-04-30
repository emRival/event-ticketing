import 'dart:ui';

import 'package:flutter/material.dart';

Color getCabangColor(String? cabang) {
  switch (cabang?.toLowerCase()) {
    case 'smp jonggol':
      return const Color.fromARGB(255, 228, 68, 218);
    case 'smk rpl jonggol':
      return Colors.purple;
    case 'smk tkj jonggol':
      return Colors.blue[900]!;
    case 'smk dkv jonggol':
      return Colors.blue;
    case 'smp akhwat':
      return Colors.cyan;
    case 'smk rpl akhwat':
      return Colors.lime;
    case 'smk dkv akhwat':
      return Colors.yellow;
    case 'smp pamijahan':
      return Colors.deepOrange;
    case 'smk rpl pamijahan':
      return Colors.red;
    case 'smk tkj pamijahan':
      return Colors.teal;
    case 'smp solo':
      return Colors.orange;
    case 'smk rpl solo':
      return Colors.green;
    case 'smk tkj solo':
      return Colors.amber;
    default:
      return Colors.grey;
  }
}
