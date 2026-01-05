import 'package:flutter/material.dart';

class RouteInfo {
  final String routeName;
  final String time;
  final String distance;
  final String elevation;
  final String difficulty;
  final Color color;

  RouteInfo({
    required this.routeName,
    required this.time,
    required this.distance,
    required this.elevation,
    required this.difficulty,
    required this.color,
  });
}
