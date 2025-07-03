import 'package:flutter/material.dart';
import 'package:foodapp/main.dart';

class LoadingUtil {
  static void show() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  static void hide() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }
}
