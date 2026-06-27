import 'package:benjii/modules/auth/service/user_profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileService.canViewBenjiiMessage', () {
    final now = DateTime.utc(2026, 6, 27);

    test('allows VIP and admin roles', () {
      expect(
        UserProfileService.canViewBenjiiMessage({'role': 'vip'}, now: now),
        isTrue,
      );
      expect(
        UserProfileService.canViewBenjiiMessage({'role': 'ADMIN'}, now: now),
        isTrue,
      );
    });

    test('allows an active VIP entitlement', () {
      expect(
        UserProfileService.canViewBenjiiMessage({
          'role': 'player',
          'vipUntil': Timestamp.fromDate(now.add(const Duration(days: 1))),
        }, now: now),
        isTrue,
      );
    });

    test('rejects ordinary, expired, and missing profiles', () {
      expect(
        UserProfileService.canViewBenjiiMessage({'role': 'player'}, now: now),
        isFalse,
      );
      expect(
        UserProfileService.canViewBenjiiMessage({
          'role': 'player',
          'vipUntil': now.subtract(const Duration(seconds: 1)),
        }, now: now),
        isFalse,
      );
      expect(UserProfileService.canViewBenjiiMessage(null, now: now), isFalse);
    });
  });
}
