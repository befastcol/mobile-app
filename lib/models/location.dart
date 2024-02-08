class LocationModel {
  final List<double> coordinates;
  final String title, subtitle;

  LocationModel({
    required this.coordinates,
    required this.title,
    required this.subtitle,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
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
