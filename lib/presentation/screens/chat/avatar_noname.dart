import 'package:flutter/material.dart';

import '../../../utils/color_util.dart';

class AvatarFromName extends StatelessWidget {
  const AvatarFromName({
    Key? key,
    String? name,
  })  : _name = name ?? "Noname",
        super(key: key);

  final String _name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color(ColorUtil.getColor(_name)),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Center(
        child: Text(
          _name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
