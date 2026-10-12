import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays a looping asset video that covers its parent and
/// paints [child] on top of it.
///
/// Internal to the package; use `VideoWalkThrough` instead.
class BackgroundVideo extends StatefulWidget {
  const BackgroundVideo({
    super.key,
    required this.asset,
    required this.child,
    this.volume = 1.0,
    this.scale = 1.0,
    this.backgroundColor = Colors.black,
  });

  /// Asset path of the video, e.g. `assets/intro.mp4`.
  final String asset;

  /// Widget painted above the video.
  final Widget child;

  /// Playback volume between 0.0 and 1.0.
  final double volume;

  /// Extra zoom applied on top of the "cover" fit.
  final double scale;

  /// Painted while the video is loading or if it fails to load.
  final Color backgroundColor;

  @override
  State<BackgroundVideo> createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  late final VideoPlayerController _controller = VideoPlayerController.asset(
    widget.asset,
  );
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(widget.volume.clamp(0.0, 1.0));
      await _controller.play();
    } catch (error) {
      // A broken or missing video must never break onboarding: keep the
      // solid background and report the problem in debug builds only.
      debugPrint('video_walkthrough: could not play "${widget.asset}": $error');
      return;
    }
    if (mounted) setState(() => _isReady = true);
  }

  @override
  void didUpdateWidget(covariant BackgroundVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.volume != widget.volume && _isReady) {
      _controller.setVolume(widget.volume.clamp(0.0, 1.0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[if (_isReady) _buildVideo(), widget.child],
      ),
    );
  }

  Widget _buildVideo() {
    final Size videoSize = _controller.value.size;
    return ClipRect(
      child: Transform.scale(
        scale: widget.scale,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: videoSize.width == 0 ? 1 : videoSize.width,
            height: videoSize.height == 0 ? 1 : videoSize.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}
