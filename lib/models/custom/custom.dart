class CreateUserResponse {
  final String userId;
  final bool alreadyExists;

  CreateUserResponse({required this.userId, required this.alreadyExists});
}

class Document {
  final String front;
  final String back;

  Document({this.front = '', this.back = ''});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      front: json['front'] ?? '',
      back: json['back'] ?? '',
    );
  }

  Document copyWith({String? front, String? back}) {
    return Document(
      front: front ?? this.front,
      back: back ?? this.back,
    );
  }
}

class Point {
  final String type;
  final List<double> coordinates;
  final String title;
  final String subtitle;

  Point({
    this.type = 'Point',
    this.coordinates = const [],
    this.title = '',
    this.subtitle = '',
  });

  factory Point.fromJson(dynamic json) {
    if (json == null) return Point();
    return Point(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates']),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'coordinates': coordinates,
        'title': title,
        'subtitle': subtitle,
        'type': type,
      };

  Point copyWith({
    String? type,
    List<double>? coordinates,
    String? title,
    String? subtitle,
  }) {
    return Point(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}

class Documents {
  final Document ine;
  final Document driverLicense;

  Documents({required this.ine, required this.driverLicense});

  factory Documents.fromJson(dynamic json) {
    return Documents(
      ine: Document.fromJson(json['INE']),
      driverLicense: Document.fromJson(json['driverLicense']),
    );
  }

  Documents copyWith({
    Document? ine,
    Document? driverLicense,
  }) {
    return Documents(
      ine: ine ?? this.ine,
      driverLicense: driverLicense ?? this.driverLicense,
    );
  }
}
