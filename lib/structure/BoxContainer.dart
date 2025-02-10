class BoxContainer {
  late double height;
  late double length;
  late double maxWeight;
  late double width;

  BoxContainer(
      {required this.height,
      required this.length,
      required this.maxWeight,
      required this.width});

  factory BoxContainer.fromJson(Map<String, dynamic> json) => BoxContainer(
        height: json['height'] ?? 0.0,
        length: json['length'] ?? 0.0,
        maxWeight: json['maxWeight'] ?? 0.0,
        width: json['width'] ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'height': height,
        'length': length,
        'maxWeight': maxWeight,
        'width': width,
      };

  @override
  String toString() {
    return 'BoxContainer{height: $height, length: $length, maxWeight: $maxWeight, width: $width}';
  }
}
