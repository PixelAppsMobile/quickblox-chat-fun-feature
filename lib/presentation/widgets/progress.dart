import 'package:flutter/material.dart';

class Progress extends StatelessWidget {
  final Alignment _alignment;
  final Color? color;

  const Progress(
    this._alignment, {
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: _alignment,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color),
        strokeWidth: 4.0,
      ),
    );
  }
}
