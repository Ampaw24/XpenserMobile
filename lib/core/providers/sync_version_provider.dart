import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incremented whenever Hive user-data is replaced (login, logout, RTDB sync).
/// Data providers watch this so they automatically rebuild from fresh Hive state.
final syncVersionProvider = StateProvider<int>((ref) => 0);
