import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:video_walkthrough/video_walkthrough.dart';

import 'fake_video_player_platform.dart';

const List<Walkthrough> _pages = <Walkthrough>[
  Walkthrough(title: 'Title 1', content: 'Content 1'),
  Walkthrough(title: 'Title 2', content: 'Content 2'),
  Walkthrough(title: 'Title 3', content: 'Content 3'),
];

const Color _active = Color(0xFFFF0000);
const Color _inactive = Color(0xFF00FF00);

Widget _app(VideoWalkThrough walkthrough) => MaterialApp(home: walkthrough);

Color? _dotColor(WidgetTester tester, int index) {
  final AnimatedContainer dot = tester.widget<AnimatedContainer>(
    find.byKey(ValueKey<String>('video_walkthrough_dot_$index')),
  );
  return (dot.decoration! as BoxDecoration).color;
}

void main() {
  late FakeVideoPlayerPlatform platform;

  setUp(() {
    platform = FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = platform;
  });

  testWidgets('shows the first page with skip, continue and one dot per page', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Title 1'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });

  testWidgets('uses the inactive color for dots that are not selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
          indicatorActiveColor: _active,
          indicatorInActiveColor: _inactive,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_dotColor(tester, 0), _active);
    expect(_dotColor(tester, 1), _inactive);
    expect(_dotColor(tester, 2), _inactive);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(_dotColor(tester, 0), _inactive);
    expect(_dotColor(tester, 1), _active);
  });

  testWidgets('continue moves to the next page', (tester) async {
    await tester.pumpWidget(
      _app(
        const VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Title 2'), findsOneWidget);
    expect(find.text('Title 1'), findsNothing);
  });

  testWidgets('skip jumps to the last page and shows start', (tester) async {
    await tester.pumpWidget(
      _app(
        const VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Title 3'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('start calls onFinish', (tester) async {
    int finished = 0;
    await tester.pumpWidget(
      _app(
        VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
          onFinish: () => finished++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(finished, 1);
  });

  testWidgets('start pushes pageRoute when onFinish is not set', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
          pageRoute: MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Home')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('start without pageRoute or onFinish does not throw', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('plays the asset video looped at the requested volume', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
          volume: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(platform.calls, contains('create:assets/intro.mp4'));
    expect(platform.calls, contains('setLooping:true'));
    expect(platform.calls, contains('play'));
    expect(platform.lastVolume, 0);
  });

  testWidgets('disposes the video player with the widget', (tester) async {
    await tester.pumpWidget(
      _app(
        const VideoWalkThrough(
          video: 'assets/intro.mp4',
          walkthroughList: _pages,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));

    expect(platform.calls, contains('dispose'));
  });

  testWidgets('asserts that walkthroughList is not empty', (tester) async {
    await tester.pumpWidget(
      _app(const VideoWalkThrough(video: 'v.mp4', walkthroughList: <Widget>[])),
    );

    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('Walkthrough applies custom text styles', (tester) async {
    const TextStyle titleStyle = TextStyle(fontSize: 40, color: _active);
    await tester.pumpWidget(
      const MaterialApp(
        home: Walkthrough(
          title: 'Hello',
          content: 'World',
          titleStyle: titleStyle,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Text title = tester.widget<Text>(find.text('Hello'));
    expect(title.style, titleStyle);
    expect(title.textAlign, TextAlign.center);
    expect(find.text('World'), findsOneWidget);
  });
}
