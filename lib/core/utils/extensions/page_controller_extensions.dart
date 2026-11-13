import 'package:flutter/widgets.dart';

extension PageControllerOffset on PageController {
  /// Fractional page position, safe to read before the PageView is laid out.
  double get pageOffset {
    if (hasClients && position.haveDimensions) {
      return page ?? initialPage.toDouble();
    }
    return initialPage.toDouble();
  }
}
