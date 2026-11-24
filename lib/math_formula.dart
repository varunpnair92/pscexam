import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';


class MathText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const MathText({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.style,
    this.maxLines,
    this.overflow,
  });

  static final RegExp _regex = RegExp(r'@(.*?)@');

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle =
        style ?? TextStyle(color: Colors.black, fontSize: fontSize);

    // ⚡ Fast path: if no '@' exists, render standard Text widget instantly with zero overhead!
    if (!text.contains('@')) {
      return Text(
        text,
        style: effectiveStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final double effectiveFontSize = effectiveStyle.fontSize ?? fontSize;
    final parts = text.split(_regex);
    final matches = _regex.allMatches(text);

    List<InlineSpan> spans = [];

    int i = 0;
    for (final match in matches) {
      if (i < parts.length && parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: effectiveStyle));
      }

      final formula = match.group(1) ?? '';
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            formula,
            textStyle: TextStyle(
              fontSize: effectiveFontSize,
              color: effectiveStyle.color,
            ),
            onErrorFallback: (err) => Text(
              formula,
              style: effectiveStyle,
            ),
          ),
        ),
      );

      i++;
    }

    if (i < parts.length && parts[i].isNotEmpty) {
      spans.add(TextSpan(text: parts[i], style: effectiveStyle));
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(
        style: effectiveStyle,
        children: spans,
      ),
    );
  }
}
