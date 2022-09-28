import 'baseelement.dart';
import 'deskelement.dart';
import 'elementwithchildren.dart';
import 'rectelement.dart';

class LayerElement extends ElementWithChildren<BaseElement> {
  LayerElement({List<BaseElement>? children}) : super(children: children);

  factory LayerElement.fromJson(Map<String, dynamic> data) {
    final children = ((data['children'] ?? []) as List).map((child) {
      switch (child['type']) {
        case 'desk':
          return DeskElement.fromJson(child);
        case 'rect':
          return RectElement.fromJson(child);
        default:
          throw Exception('Invalid layer child: $child');
      }
    }).toList();

    return LayerElement(children: children);
  }
}
