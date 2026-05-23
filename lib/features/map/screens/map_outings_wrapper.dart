import 'package:flutter/material.dart';
import '../../dashboard/screens/outings_screen.dart';
import 'map_screen.dart';

class MapOutingsWrapper extends StatefulWidget {
  const MapOutingsWrapper({super.key});

  @override
  State<MapOutingsWrapper> createState() => _MapOutingsWrapperState();
}

class _MapOutingsWrapperState extends State<MapOutingsWrapper> {
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    if (_showMap) {
      return MapScreen(
        onToggleOutings: () {
          setState(() {
            _showMap = false;
          });
        },
      );
    } else {
      return OutingsScreen(
        onToggleMap: () {
          setState(() {
            _showMap = true;
          });
        },
      );
    }
  }
}
