import 'package:awesome_scroll_actions/awesome_scroll_actions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const arc = QuickActionsArc();
  const size = Size(390, 844);

  test('selected item lands on the design coordinates', () {
    final p = arc.place(index: 4, position: 4, openness: 1, size: size);
    expect(p.center.dx, closeTo(330, 1e-9));
    expect(p.center.dy, closeTo(430, 1e-9));
    expect(p.opacity, 1);
    expect(p.scale, 1);
    expect(p.distance, 0);
  });

  test('neighbours fade and shrink with angular distance', () {
    final p = arc.place(index: 5, position: 4, openness: 1, size: size);
    expect(p.opacity, closeTo(1 - 0.232 * 1.15, 1e-9));
    expect(p.scale, closeTo(1 - 0.232 * 0.22, 1e-9));
    expect(p.center.dy, greaterThan(430));
  });

  test('scale never drops below 0.78', () {
    final p = arc.place(index: 9, position: 0, openness: 1, size: size);
    expect(p.scale, 0.78);
    expect(p.opacity, 0);
  });

  test('tucking slides items right and hides them', () {
    final p = arc.place(index: 4, position: 4, openness: 0, size: size);
    expect(p.center.dx, closeTo(330 + 210, 1e-9));
    expect(p.opacity, 0);
  });
}
