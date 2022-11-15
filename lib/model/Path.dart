class TablePath {
  int startLocation;
  int endLocation;

  TablePath({
    required this.startLocation,
    required this.endLocation,
  });

  factory TablePath.fromJson(Map<String, dynamic> data) {
    return TablePath(
      startLocation: data['start_location'],
      endLocation: data['end_location'],
    );
  }
}
