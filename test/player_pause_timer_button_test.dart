import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/player/view/player_pause_timer_button.dart';

void main() {
  group('durationUntilNextTimeOfDay', () {
    test('uses today when the target time is still ahead', () {
      final duration = durationUntilNextTimeOfDay(
        targetTime: const TimeOfDay(hour: 23, minute: 50),
        now: DateTime(2026, 5, 16, 23, 49),
      );

      expect(duration, const Duration(minutes: 1));
    });

    test('rolls over to tomorrow when the target time already passed', () {
      final duration = durationUntilNextTimeOfDay(
        targetTime: const TimeOfDay(hour: 23, minute: 48),
        now: DateTime(2026, 5, 16, 23, 49),
      );

      expect(duration, const Duration(hours: 23, minutes: 59));
    });

    test('rolls over to tomorrow when the target time is the same minute', () {
      final duration = durationUntilNextTimeOfDay(
        targetTime: const TimeOfDay(hour: 23, minute: 49),
        now: DateTime(2026, 5, 16, 23, 49),
      );

      expect(duration, const Duration(days: 1));
    });
  });
}
