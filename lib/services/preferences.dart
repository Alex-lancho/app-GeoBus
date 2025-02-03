import 'package:app_ruta/widgets/home_geo_bus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<void> changeRole(BuildContext context, String rol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(rol);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => GeoBusHome()),
      (Route<dynamic> route) => false,
    );
  }
}
