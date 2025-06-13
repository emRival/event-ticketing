import 'package:flutter/material.dart';

const Map<String, Color> _cabangColorMap = {
  'smp idn jonggol': Color(0xFF0967EC),
  'smk rpl idn jonggol': Color(0xFF0967EC),
  'smk tkj idn jonggol': Color(0xFF0967EC),
  'smk dkv idn jonggol': Color(0xFF0967EC),
  'smp idn akhwat': Color(0xFFAB00FA),
  'smk rpl idn akhwat': Color(0xFFAB00FA),
  'smk dkv idn akhwat': Color(0xFFAB00FA),
  'smp idn pamijahan': Color(0xFF41B375),
  'smk rpl idn pamijahan': Color(0xFF41B375),
  'smk tkj idn pamijahan': Color(0xFF41B375),
  'smpn idn solo': Color(0xFFF89803),
  'smk rpl idn solo': Color(0xFFF89803),
  'smk tkj idn solo': Color(0xFFF89803),
  'idn jonggol': Color(0xFF1E5194),
  'idn pamijahan': Color(0xFF1E5194),
  'idn solo': Color(0xFF1E5194),
  'idn akhwat': Color(0xFF56008F),
};

Color getCabangColor(String? cabang) {
  return _cabangColorMap[cabang?.toLowerCase()] ?? Colors.grey;
}
