class Location {
  final List<double> coordinates;
  final String title;
  final String subtitle;

  Location({
    required this.coordinates,
    required this.title,
    required this.subtitle,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      coordinates: List<double>.from(json['coordinates']),
      title: json['title'],
      subtitle: json['subtitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates,
      'title': title,
      'subtitle': subtitle,
    };
  }
}
