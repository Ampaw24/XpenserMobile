import 'package:expenser/views/shell/widgets/animated_branch_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Counter extends StatefulWidget {
  const _Counter(this.label);
  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => taps++),
      child: Text('${widget.label}:$taps'),
    ),
  );
}

Widget _host(int index, {bool reduceMotion = false}) => MaterialApp(
  home: Builder(
    builder:
        (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: AnimatedBranchContainer(
            currentIndex: index,
            children: const [_Counter('a'), _Counter('b')],
          ),
        ),
  ),
);

void main() {
  testWidgets('only the active tab receives taps and state is kept', (
    tester,
  ) async {
    await tester.pumpWidget(_host(0));
    await tester.tap(find.text('a:0'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('a:1'), findsOneWidget);

    await tester.pumpWidget(_host(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('b:0'), warnIfMissed: false);
    await tester.tap(find.text('a:1'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('b:1'), findsOneWidget);
    expect(find.text('a:1'), findsOneWidget);

    await tester.pumpWidget(_host(0));
    await tester.pumpAndSettle();
    expect(find.text('a:1'), findsOneWidget);
    expect(find.text('b:1'), findsOneWidget);
  });

  for (final reduceMotion in [false, true]) {
    testWidgets('animates tab switch unless reduced motion '
        '(reduceMotion: $reduceMotion)', (tester) async {
      await tester.pumpWidget(_host(0, reduceMotion: reduceMotion));
      await tester.pumpWidget(_host(1, reduceMotion: reduceMotion));
      await tester.pump();
      expect(tester.hasRunningAnimations, !reduceMotion);
      await tester.pumpAndSettle();
    });
  }
}
