class Location {
  final String type;
  final List<double> coordinates;
  final String label;

  Location({
    required this.type,
    required this.coordinates,
    required this.label,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
      label: json['label'],
    );
  }
}
