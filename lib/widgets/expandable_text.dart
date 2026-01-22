import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int trimLines;

  const ExpandableText(
    this.text, {
    super.key,
    required this.style,
    this.trimLines = 3,
  });

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // A widget that builds itself based on the layout of its child.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Use a TextPainter to determine if the text will exceed the trimLines
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        // Check if the text has overflowed
        final bool isTextOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                widget.text,
                style: widget.style,
                maxLines: widget.trimLines,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(widget.text, style: widget.style),
            ),
            if (isTextOverflowing)
              GestureDetector(
                onTap: _toggleExpanded,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _isExpanded ? 'Read Less' : 'Read More',
                    style: widget.style.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(), // Don't show anything if not needed
          ],
        );
      },
    );
  }
}
