import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodapp/services/connected_internet.dart';
import 'package:foodapp/main.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

class NetworkStatusOverlay extends StatefulWidget {
  const NetworkStatusOverlay({super.key});

  @override
  State<NetworkStatusOverlay> createState() => _NetworkStatusOverlayState();
}

class _NetworkStatusOverlayState extends State<NetworkStatusOverlay> {
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkStatusService().connectionState,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data! && !_isDialogShowing) {
          _isDialogShowing = true;
          Future.delayed(Duration.zero, () {
            if (mounted) {
              _showConnectionDialog();
            }
          });
        } else if (snapshot.hasData && snapshot.data! && _isDialogShowing) {
          _isDialogShowing = false;
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showConnectionDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isDialogShowing = false;
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      _isDialogShowing = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child:
                      const Icon(Icons.wifi_off, color: Colors.red, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mất kết nối',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Không thể kết nối đến máy chủ.\nVui lòng kiểm tra lại kết nối mạng của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          _isDialogShowing = false;
                          await NetworkStatusService().retryConnection();
                        },
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.orange3,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _isDialogShowing = false;
                          SystemNavigator.pop();
                        },
                        icon: const Icon(Icons.exit_to_app, size: 20),
                        label: const Text('Thoát'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
