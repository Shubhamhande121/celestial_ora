import 'package:flutter/foundation.dart';

class ListOfSelectedFilters extends ChangeNotifier {
  final List<String> _selectedCategoryIds = [];

  List<String> get selectedCategoryIds => _selectedCategoryIds;

  void addItem(String id) {
    _selectedCategoryIds.add(id);
    notifyListeners();
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
