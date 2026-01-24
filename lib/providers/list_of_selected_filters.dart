import 'package:flutter/foundation.dart';

class ListOfSelectedFilters extends ChangeNotifier {
  final List<String> _selectedCategoryIds = [];

  // 🔥 RETURN A NEW LIST
  List<String> get selectedCategoryIds =>
      List.unmodifiable(_selectedCategoryIds);

  // 🔥 REQUIRED for API
  String get selectedIdsAsString => _selectedCategoryIds.join(',');

  void addItem(String id) {
    if (!_selectedCategoryIds.contains(id)) {
      _selectedCategoryIds.add(id);
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _selectedCategoryIds.remove(id);
    notifyListeners();
  }

  void clearItems() {
    _selectedCategoryIds.clear();
    notifyListeners();
  }

  bool isSelected(String categoryId) {
    return _selectedCategoryIds.contains(categoryId);
  }
}
