import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> checkLocationPermission() async {
    return await Permission.locationWhenInUse.status;
  }

  Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.locationWhenInUse.request();
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
