import 'package:flutter/material.dart';

class DecoratedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double _shadowHeight = 0;

  const DecoratedAppBar({
    Key? key,
    required this.appBar,
  }) : super(key: key);

  final PreferredSizeWidget appBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(186, 49, 122, 255),
                offset: Offset(0, 3),
                blurRadius: 9.0,
              )
            ],
          ),
          child: appBar,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + _shadowHeight);
}
