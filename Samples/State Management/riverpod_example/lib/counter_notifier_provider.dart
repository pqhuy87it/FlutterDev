// counter_provider.dart (sửa lại)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'counter_notifier.dart';

final counterNotifierProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});