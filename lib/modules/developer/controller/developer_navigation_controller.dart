import 'package:flutter/foundation.dart';

class DeveloperNavigationController extends ChangeNotifier {
  DeveloperNavigationController._();

  static final instance = DeveloperNavigationController._();

  int? _requestedStoryPageIndex;

  int? takeRequestedStoryPageIndex() {
    final index = _requestedStoryPageIndex;
    _requestedStoryPageIndex = null;
    return index;
  }

  void requestStoryPage(int index) {
    _requestedStoryPageIndex = index;
    notifyListeners();
  }
}
