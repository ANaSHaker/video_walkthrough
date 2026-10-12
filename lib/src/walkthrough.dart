import 'package:flutter/material.dart';

/// A single page of a [VideoWalkThrough].
///
/// Shows a [title] and a [content] paragraph that slide in from the left
/// the first time the page is built.
///
/// ```dart
/// const Walkthrough(
///   title: 'Discover places',
///   content: 'Find events and places in every city.',
/// )
/// ```
class Walkthrough extends StatefulWidget {
  /// Creates a walkthrough page.
  const Walkthrough({
    super.key,
    required this.title,
    required this.content,
    this.titleStyle,
    this.contentStyle,
    this.textAlign = TextAlign.center,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  /// Headline of the page.
  final String title;

  /// Body text shown under the [title].
  final String content;

  /// Style of the [title]. Defaults to white, 24 logical pixels.
  final TextStyle? titleStyle;

  /// Style of the [content]. Defaults to white, 16 logical pixels, w500.
  final TextStyle? contentStyle;

  /// Alignment of both texts. Defaults to [TextAlign.center].
  final TextAlign textAlign;

  /// Duration of the slide-in animation.
  final Duration animationDuration;

  @override
  State<Walkthrough> createState() => _WalkthroughState();
}

class _WalkthroughState extends State<Walkthrough>
    with SingleTickerProviderStateMixin {
  static const double _slideDistance = 250;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  )..forward();

  late final Animation<double> _offset = Tween<double>(
    begin: -_slideDistance,
    end: 0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) => Transform.translate(
        offset: Offset(_offset.value, 0),
        child: Opacity(opacity: _controller.value, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.title,
              textAlign: widget.textAlign,
              style: widget.titleStyle ??
                  const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              widget.content,
              textAlign: widget.textAlign,
              style: widget.contentStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
