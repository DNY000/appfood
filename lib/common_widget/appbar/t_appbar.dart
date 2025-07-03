import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.showBackArrow = false,
    this.centerTitle = true,
    this.padding = 0,
    this.action,
    this.leadingOnPressed,
  });

  final Widget? title;
  final IconData? leadingIcon;
  final bool showBackArrow;
  final List<Widget>? action;
  final VoidCallback? leadingOnPressed;
  final double padding;
  final bool centerTitle;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: padding,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: centerTitle,
      leading: showBackArrow
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            )
          : leadingIcon != null
              ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon))
              : null,
      title: title,
      actions: action,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
