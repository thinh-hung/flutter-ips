import 'layerelement.dart';
import 'elementwithchildren.dart';

class RootElement extends ElementWithChildren<LayerElement> {
  final String locationId;

  get layers => children;

  RootElement({
    List<LayerElement>? children,
    required this.locationId,
  }) : super(children: children);

  factory RootElement.fromJson(Map<String, dynamic> data, String type) {
    final children = ((data['children'] ?? []) as List).map((child) {
      switch (child['type']) {
        case 'layer':
          return LayerElement.fromJson(child, type);
        default:
          throw Exception('Invalid root element child: $child');
      }
    }).toList();

    return RootElement(
      children: children,
      locationId: data['locationId'],
    );
  }
}
