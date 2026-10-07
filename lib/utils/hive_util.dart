import 'package:hive_ce/hive.dart';

void deleteWithPrefix(Box box, String prefix) {
  for (final i in box.keys) {
    if ((i as String).startsWith(prefix)) {
      box.delete(i);
    }
  }
}

Future<void> deleteWithPrefixAsync(LazyBox box, String prefix) async {
  for (final i in box.keys) {
    if ((i as String).startsWith(prefix)) {
      await box.delete(i);
    }
  }
}
