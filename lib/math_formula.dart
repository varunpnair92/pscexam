import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';


class MathText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextStyle? style;

  const MathText({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(r'@(.*?)@');

    final parts = text.split(regex);
    final matches = regex.allMatches(text);

    final TextStyle effectiveStyle =
        style ?? TextStyle(color: Colors.black, fontSize: fontSize);
    final double effectiveFontSize = effectiveStyle.fontSize ?? fontSize;

    List<InlineSpan> spans = [];

    int i = 0;
    for (final match in matches) {
      spans.add(TextSpan(text: parts[i], style: effectiveStyle));

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            match.group(1)!,
            textStyle: TextStyle(
              fontSize: effectiveFontSize,
              color: effectiveStyle.color,
            ),
          ),
        ),
      );

      i++;
    }

    if (i < parts.length) {
      spans.add(TextSpan(text: parts[i], style: effectiveStyle));
    }

    return RichText(
      text: TextSpan(
        style: effectiveStyle,
        children: spans,
      ),
    );
  }
}
