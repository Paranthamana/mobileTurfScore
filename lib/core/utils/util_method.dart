import 'dart:developer' as criflog;

import 'package:flutter/foundation.dart';

class UtilMethod {
  static void debugLog(String message) {
    if (kDebugMode) {
      criflog.log(message);
    }
  }
}
