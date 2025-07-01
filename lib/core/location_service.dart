import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Position? _lastKnownPosition;
  static DateTime? _lastUpdateTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 10);
  static bool hasAskedPermission = false;
  static bool _isDialogShowing = false;
  static bool _showRetryButton = false;

  static Future<Position?> getCurrentLocation(BuildContext context) async {
    try {
      // Check if we have a recent cached position
      if (_lastKnownPosition != null && _lastUpdateTime != null) {
        final timeDiff = DateTime.now().difference(_lastUpdateTime!);
        if (timeDiff < _cacheTimeout) {
          return _lastKnownPosition;
        }
      }

      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted && !hasAskedPermission && !_isDialogShowing) {
          showLocationPermissionDialog(context);
        }
        return null;
      }

      // Check location permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            _showSnackBar(context, 'Quyền truy cập vị trí bị từ chối');
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          _showPermissionBlockedDialog(context);
        }
        return null;
      }

      // Try to get location with retries
      Position? position;
      int retryCount = 0;

      while (position == null && retryCount < _maxRetries) {
        try {
          position = await Geolocator.getCurrentPosition(
            // ignore: deprecated_member_use
            desiredAccuracy: LocationAccuracy.high,
            // ignore: deprecated_member_use
            timeLimit: _timeout,
          );
        } catch (e) {
          retryCount++;
          if (retryCount == _maxRetries) {
            if (context.mounted) {
              _showSnackBar(
                  context, 'Không thể lấy vị trí sau $retryCount lần thử');
            }
            return null;
          }
          await Future.delayed(Duration(seconds: retryCount));
        }
      }

      if (position != null) {
        _lastKnownPosition = position;
        _lastUpdateTime = DateTime.now();
      }

      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Có lỗi khi lấy vị trí: $e');
      }
      return null;
    }
  }

  static void showLocationPermissionDialog(BuildContext context) {
    if (_isDialogShowing || hasAskedPermission) return;
    _isDialogShowing = true;
    hasAskedPermission = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          //  contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          title: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.2), width: 1)),
                padding: const EdgeInsets.all(16),
                child: Icon(Icons.location_on, color: TColor.orange3, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cấp quyền vị trí',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  // color: Colors.blue,
                ),
              ),
            ],
          ),
          content: const Text(
            'Để tìm quán ăn gần bạn. Vui lòng cho phép ứng dụng truy cập vị trí của bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _isDialogShowing = false;
                        _showRetryButton = true;
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hỏi lại sau'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        _isDialogShowing = false;
                        await Geolocator.openLocationSettings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Bật vị trí',
                        style: TextStyle(color: TColor.color3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showPermissionBlockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quyền truy cập vị trí bị chặn'),
          content: const Text(
            'Bạn đã chặn quyền truy cập vị trí. Vui lòng vào cài đặt để cho phép ứng dụng truy cập vị trí.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Đóng'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Mở Cài đặt'),
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ],
        );
      },
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static void clearCache() {
    _lastKnownPosition = null;
    _lastUpdateTime = null;
  }

  /// Chuyển đổi từ vị trí (Position) thành địa chỉ (String)
  static Future<String?> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String address = [
          place.street,
          // place.subLocality,
          // place.thoroughfare,
          // place.locality,
          // place.subAdministrativeArea,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        if (place.administrativeArea == 'Ha Noi') {
          address = address.replaceAll('Ha Noi', 'Hà Nội');
        }
        return address;
      }
      return null;
    } catch (e) {
      debugPrint('Error converting position to address: $e');
      return null;
    }
  }

  static Widget buildRetryLocationButton(BuildContext context) {
    if (!_showRetryButton) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.location_searching),
        label: const Text('Thử lại cấp quyền vị trí'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          hasAskedPermission = false;
          _showRetryButton = false;
          showLocationPermissionDialog(context);
        },
      ),
    );
  }
}
