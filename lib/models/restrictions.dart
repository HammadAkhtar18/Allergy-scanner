import 'dart:convert';

import 'package:flutter/foundation.dart';

class RestrictionsModel extends ChangeNotifier {
  RestrictionsModel({required this.initialRestrictions}) {
    _restrictions
      ..clear()
      ..addAll(initialRestrictions);
  }

  final List<String> initialRestrictions;
  final List<String> _restrictions = [];

  List<String> get restrictions => List.unmodifiable(_restrictions);

  void addRestriction(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty || _restrictions.contains(normalized)) {
      return;
    }
    _restrictions.add(normalized);
    notifyListeners();
  }

  void removeRestriction(String value) {
    _restrictions.remove(value);
    notifyListeners();
  }

  void replaceAll(List<String> values) {
    _restrictions
      ..clear()
      ..addAll(values.map((value) => value.trim().toLowerCase()).where((value) => value.isNotEmpty));
    notifyListeners();
  }

  String toJson() => jsonEncode(_restrictions);

  static List<String> fromJson(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return [];
    }
    return decoded.whereType<String>().map((value) => value.trim().toLowerCase()).toList();
  }
}
