class AdSlot {
  final String id;
  final String name;
  final String location;
  final String area;
  final String city;
  final String imageUrl;
  final double pricePerDay;
  final int screenWidth;
  final int screenHeight;
  final double footTraffic; // daily footfall in thousands
  final bool isAvailable;
  final String type; // 'local' | 'premium'

  const AdSlot({
    required this.id,
    required this.name,
    required this.location,
    required this.area,
    required this.city,
    required this.imageUrl,
    required this.pricePerDay,
    required this.screenWidth,
    required this.screenHeight,
    required this.footTraffic,
    required this.isAvailable,
    required this.type,
  });

  factory AdSlot.fromJson(Map<String, dynamic> json) => AdSlot(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        location: json['location'] as String? ??
            json['full_address'] as String? ??
            '',
        area: json['area'] as String? ?? '',
        city: json['city'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 0,
        screenWidth: (json['screen_width'] as num?)?.toInt() ?? 0,
        screenHeight: (json['screen_height'] as num?)?.toInt() ?? 0,
        footTraffic: (json['foot_traffic'] as num?)?.toDouble() ?? 0,
        isAvailable: json['is_available'] as bool? ?? true,
        type: json['type'] as String? ?? 'local',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'area': area,
        'city': city,
        'image_url': imageUrl,
        'price_per_day': pricePerDay,
        'screen_width': screenWidth,
        'screen_height': screenHeight,
        'foot_traffic': footTraffic,
        'is_available': isAvailable,
        'type': type,
      };

  String get aspectRatioLabel => '$screenWidth x $screenHeight px';
  String get priceLabel => '₹${pricePerDay.toStringAsFixed(0)}/day';
  String get footTrafficLabel => '${footTraffic.toStringAsFixed(1)}K daily';
}
