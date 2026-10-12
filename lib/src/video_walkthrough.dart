import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'background_video.dart';
import 'walkthrough.dart';

/// A full-screen onboarding flow: a looping background [video] with swipeable
/// [walkthroughList] pages, dot indicators, a *Skip* button, a *Continue*
/// button and a final *Start* button.
///
/// When the user taps *Start*, [onFinish] is called if provided; otherwise
/// [pageRoute] is pushed (or replaces the walkthrough when
/// [replaceOnFinish] is `true`). If neither is set, *Start* does nothing.
///
/// ```dart
/// VideoWalkThrough(
///   video: 'assets/intro.mp4',
///   walkthroughList: const [
///     Walkthrough(title: 'Welcome', content: 'Let us show you around.'),
///     Walkthrough(title: 'Explore', content: 'Find places near you.'),
///   ],
///   onFinish: () => Navigator.of(context).pushReplacementNamed('/home'),
/// )
/// ```
class VideoWalkThrough extends StatefulWidget {
  /// Creates a video walkthrough. [walkthroughList] must not be empty.
  const VideoWalkThrough({
    super.key,
    required this.walkthroughList,
    required this.video,
    this.pageRoute,
    this.onFinish,
    this.replaceOnFinish = false,
    this.volume = 1.0,
    this.videoScale = 1.0,
    this.dotSize = 8.0,
    this.indicatorActiveColor = Colors.white,
    this.indicatorInActiveColor = Colors.white54,
    this.skipText = 'Skip',
    this.skipStyle,
    this.continueText = 'Continue',
    this.continueStyle,
    this.continueBorderColor = Colors.white,
    this.startText = 'Start',
    this.startStyle,
    this.startBtnColor = Colors.indigoAccent,
    this.smallImage,
    this.smallImageSize = 100,
    this.smallImageColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.hideSystemOverlays = true,
  });

  /// Pages shown in the [PageView], usually [Walkthrough] widgets.
  final List<Widget> walkthroughList;

  /// Asset path of the background video, e.g. `assets/intro.mp4`.
  final String video;

  /// Route opened when the user taps *Start* and [onFinish] is null.
  final Route<Object?>? pageRoute;

  /// Called when the user taps *Start*. Takes precedence over [pageRoute].
  final VoidCallback? onFinish;

  /// Whether [pageRoute] replaces the walkthrough instead of being pushed
  /// on top of it.
  final bool replaceOnFinish;

  /// Video volume between 0.0 (muted) and 1.0.
  final double volume;

  /// Extra zoom applied to the video, which already covers the screen.
  final double videoScale;

  /// Diameter of each indicator dot.
  final double dotSize;

  /// Color of the dot for the current page.
  final Color indicatorActiveColor;

  /// Color of the dots for the other pages.
  final Color indicatorInActiveColor;

  /// Label of the top-right skip button.
  final String skipText;

  /// Style of [skipText].
  final TextStyle? skipStyle;

  /// Label of the button that moves to the next page.
  final String continueText;

  /// Style of [continueText].
  final TextStyle? continueStyle;

  /// Border color of the continue button.
  final Color continueBorderColor;

  /// Label of the button shown on the last page.
  final String startText;

  /// Style of [startText].
  final TextStyle? startStyle;

  /// Background color of the start button.
  final Color startBtnColor;

  /// Optional asset image (e.g. a logo) shown above the pages.
  final String? smallImage;

  /// Width of [smallImage].
  final double smallImageSize;

  /// Tint applied to [smallImage]; pass `null` to keep its original colors.
  final Color? smallImageColor;

  /// Painted while the video loads, or if it cannot be played.
  final Color backgroundColor;

  /// Hides the status and navigation bars while the walkthrough is visible
  /// and restores them when it is disposed.
  final bool hideSystemOverlays;

  @override
  State<VideoWalkThrough> createState() => _VideoWalkThroughState();
}

class _VideoWalkThroughState extends State<VideoWalkThrough> {
  static const Duration _pageDuration = Duration(milliseconds: 350);
  static const Duration _dotDuration = Duration(milliseconds: 150);

  final PageController _controller = PageController();
  int _currentPage = 0;

  int get _lastPage => widget.walkthroughList.length - 1;
  bool get _isLastPage => _currentPage == _lastPage;

  @override
  void initState() {
    super.initState();
    assert(
      widget.walkthroughList.isNotEmpty,
      'VideoWalkThrough.walkthroughList must not be empty',
    );
    if (widget.hideSystemOverlays) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
  }

  @override
  void dispose() {
    if (widget.hideSystemOverlays) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    _controller.nextPage(duration: _pageDuration, curve: Curves.easeInOut);
  }

  void _skipToEnd() => _controller.jumpToPage(_lastPage);

  void _finish() {
    final VoidCallback? onFinish = widget.onFinish;
    if (onFinish != null) {
      onFinish();
      return;
    }
    final Route<Object?>? route = widget.pageRoute;
    if (route == null) return;
    final NavigatorState navigator = Navigator.of(context);
    if (widget.replaceOnFinish) {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: BackgroundVideo(
        asset: widget.video,
        volume: widget.volume,
        scale: widget.videoScale,
        backgroundColor: widget.backgroundColor,
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    final String? smallImage = widget.smallImage;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Align(alignment: AlignmentDirectional.topEnd, child: _buildSkip()),
          if (smallImage != null && smallImage.isNotEmpty)
            Image.asset(
              smallImage,
              color: widget.smallImageColor,
              width: widget.smallImageSize,
            ),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: widget.walkthroughList,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              widget.walkthroughList.length,
              (index) => _buildDot(index, isActive: index == _currentPage),
            ),
          ),
          SizedBox(
            height: 120,
            child: Center(
              child: _isLastPage ? _buildStart() : _buildContinue(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkip() {
    return TextButton(
      onPressed: _skipToEnd,
      child: Text(
        widget.skipText,
        style: widget.skipStyle ??
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
      ),
    );
  }

  Widget _buildDot(int index, {required bool isActive}) {
    return AnimatedContainer(
      key: ValueKey<String>('video_walkthrough_dot_$index'),
      duration: _dotDuration,
      height: widget.dotSize,
      width: widget.dotSize,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive
            ? widget.indicatorActiveColor
            : widget.indicatorInActiveColor,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget _buildContinue() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(200, 45),
        shape: const StadiumBorder(),
        side: BorderSide(color: widget.continueBorderColor),
      ),
      onPressed: _nextPage,
      child: Text(
        widget.continueText,
        style: widget.continueStyle ?? const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildStart() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 45),
        backgroundColor: widget.startBtnColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      onPressed: _finish,
      child: Text(
        widget.startText,
        style: widget.startStyle ?? const TextStyle(color: Colors.white),
      ),
    );
  }
}
