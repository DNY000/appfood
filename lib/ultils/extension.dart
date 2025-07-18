import 'package:flutter/material.dart';

extension CommonExtension on State {
  void endEditing() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
  // chuyển focus sang một FocusNode mới, qua đó loại bỏ focus khỏi bất kỳ widget nào đang có focus, chẳng hạn như trường nhập văn bản.
}

  extension DateTimeFormatter on DateTime{
   String formatDMYHM(){
    return "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year "
           "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
   }


  }