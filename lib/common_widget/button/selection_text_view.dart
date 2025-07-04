import 'package:flutter/material.dart';

import '../../ultils/const/color_extension.dart';

class SelectionTextView extends StatelessWidget {
  final String title;
  final String actionTitle;
  final VoidCallback onSeeAllTap;
  const SelectionTextView(
      {super.key,
      required this.title,
      required this.onSeeAllTap,
      this.actionTitle = "Xem tất cả"});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(left: 12,top: 8, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: TColor.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 35,
              child: TextButton(
                onPressed: onSeeAllTap,
                child: Text(
                  actionTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: TColor.orange5,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
