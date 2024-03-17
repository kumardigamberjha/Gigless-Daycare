import 'package:childcare/constant.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final void Function() press;
  final Color color, textColor;
  const RoundedButton({
    super.key,
    required this.text,
    required this.press,
    this.color = KPrimaryColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: size.width * 0.8,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: textColor, // Background color
            backgroundColor: color,
            elevation: 10, // Shadow depth
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: press,
          child: Text(text),
        ));
  }
}
