import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';


class MathText extends StatelessWidget {
  final String text;
  final double fontSize;

  const MathText({super.key, required this.text, this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'@(.*?)@');

    final parts = text.split(regex);
    final matches = regex.allMatches(text);

    List<InlineSpan> spans = [];

    int i = 0;
    for (final match in matches) {
      spans.add(TextSpan(text: parts[i]));

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            match.group(1)!,
            textStyle: TextStyle(fontSize: fontSize),
          ),
        ),
      );

      i++;
    }

    if (i < parts.length) {
      spans.add(TextSpan(text: parts[i]));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: fontSize),
        children: spans,
      ),
    );
  }
}
