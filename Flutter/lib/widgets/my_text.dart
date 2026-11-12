import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  const MyText(
    this.texte,
    this.color,
    this.size,
    this.fontWeight, {
    super.key,
  });

  final String texte;
  final Color color;
  final double size;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
      ),
    );
  }
}
