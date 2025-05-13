import 'package:flutter/material.dart';

const Map<String, Color> _cabangColorMap = {
  'smp jonggol': Color(0xFF0967EC),
  'smk rpl jonggol': Color(0xFF0967EC),
  'smk tkj jonggol': Color(0xFF0967EC),
  'smk dkv jonggol': Color(0xFF0967EC),
  'smp akhwat': Color(0xFFF89803),
  'smk rpl akhwat': Color(0xFFF89803),
  'smk dkv akhwat': Color(0xFFF89803),
  'smp pamijahan': Color(0xFF41B375),
  'smk rpl pamijahan': Color(0xFF41B375),
  'smk tkj pamijahan': Color(0xFF41B375),
  'smp solo': Color(0xFFAB00FA),
  'smk rpl solo': Color(0xFFAB00FA),
  'smk tkj solo': Color(0xFFAB00FA),
  'guru idn ikhwan': Color(0xFF1E5194),
  'guru idn akhwat': Color(0xFF56008F),
};

Color getCabangColor(String? cabang) {
  return _cabangColorMap[cabang?.toLowerCase()] ?? Colors.grey;
}
