import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_test/flutter_test.dart';

Widget _app({required bool infinite, required List<int> seen, int count = 3}) =>
    MaterialApp(
      home: Scaffold(
        body: CarouselSlider.builder(
          itemCount: count,
          itemBuilder: (_, i, __) => Text('slide $i'),
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.85,
            autoPlay: count > 1,
            autoPlayInterval: const Duration(seconds: 1),
            autoPlayAnimationDuration: const Duration(milliseconds: 200),
            enableInfiniteScroll: infinite,
            onPageChanged: (i, _) => seen.add(i),
          ),
        ),
      ),
    );

Future<void> _run(WidgetTester t, int seconds) async {
  for (var i = 0; i < seconds * 10; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('infinite autoplay goes past the last slide to the first',
      (t) async {
    final seen = <int>[];
    await t.pumpWidget(_app(infinite: true, seen: seen));
    expect(find.text('slide 0'), findsOneWidget);
    await _run(t, 7);
    expect(seen.take(6).toList(), [1, 2, 0, 1, 2, 0]);
  });

  testWidgets('infinite: swiping back from the first slide shows the last',
      (t) async {
    final seen = <int>[];
    await t.pumpWidget(_app(infinite: true, seen: seen));
    await t.fling(find.text('slide 0'), const Offset(400, 0), 1000);
    await t.pump(const Duration(milliseconds: 600));
    expect(seen.first, 2);
  });

  testWidgets('finite mode still stops on the last slide by swipe', (t) async {
    final seen = <int>[];
    await t.pumpWidget(_app(infinite: false, seen: seen));
    await t.fling(find.text('slide 0'), const Offset(400, 0), 1000);
    await t.pump(const Duration(milliseconds: 600));
    expect(seen, isEmpty);
  });

  testWidgets('one slide: no autoplay, no crash', (t) async {
    final seen = <int>[];
    await t.pumpWidget(_app(infinite: false, seen: seen, count: 1));
    await _run(t, 3);
    expect(seen, isEmpty);
    expect(find.text('slide 0'), findsOneWidget);
  });
}
