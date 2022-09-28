import 'package:flutter/material.dart';
import 'baseelement.dart';

class ElementWithChildren<T extends BaseElement> implements BaseElement {
  final List<T> _children;

  ElementWithChildren({
    List<T>? children,
  }) : _children = children ?? [];

  get children => _children;

  @override
  Rect getExtent() {
    double left = 0, right = 0, top = 0, bottom = 0;
    for (var child in _children) {
      final extent = child.getExtent();
      if (extent.left < left) {
        left = extent.left;
      }
      if (extent.top < top) {
        top = extent.top;
      }
      if (extent.right > right) {
        right = extent.right;
      }
      if (extent.bottom > bottom) {
        bottom = extent.bottom;
      }
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
