class AdSlot {
  final String  id;
  final String  name;
  final String  location;
  final String  area;
  final String  city;
  final String  imageUrl;
  final double  pricePerDay;
  final int     screenWidth;
  final int     screenHeight;
  final double  footTraffic;  // daily footfall in thousands
  final bool    isAvailable;
  final String  type;         // 'local' | 'premium'

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
        id:           json['id']           as String,
        name:         json['name']         as String,
        location:     json['location']     as String,
        area:         json['area']         as String,
        city:         json['city']         as String,
        imageUrl:     json['image_url']    as String,
        pricePerDay:  (json['price_per_day'] as num).toDouble(),
        screenWidth:  json['screen_width']  as int,
        screenHeight: json['screen_height'] as int,
        footTraffic:  (json['foot_traffic'] as num).toDouble(),
        isAvailable:  json['is_available']  as bool,
        type:         json['type']          as String,
      );

  Map<String, dynamic> toJson() => {
        'id':           id,
        'name':         name,
        'location':     location,
        'area':         area,
        'city':         city,
        'image_url':    imageUrl,
        'price_per_day': pricePerDay,
        'screen_width':  screenWidth,
        'screen_height': screenHeight,
        'foot_traffic':  footTraffic,
        'is_available':  isAvailable,
        'type':          type,
      };

  String get aspectRatioLabel => '$screenWidth x $screenHeight px';
  String get priceLabel       => '₹${pricePerDay.toStringAsFixed(0)}/day';
  String get footTrafficLabel => '${footTraffic.toStringAsFixed(1)}K daily';

  // ── Mock data for UI testing ───────────────────────────────────────────────
  static List<AdSlot> mockLocalSlots = [
    const AdSlot(
      id:           'slot_001',
      name:         'City Centre Mall',
      location:     'Main Entrance Lobby',
      area:         'Anna Nagar',
      city:         'Chennai',
      imageUrl:     'https://picsum.photos/seed/slot1/400/300',
      pricePerDay:  500,
      screenWidth:  1920,
      screenHeight: 1080,
      footTraffic:  12.5,
      isAvailable:  true,
      type:         'local',
    ),
    const AdSlot(
      id:           'slot_002',
      name:         'Metro Station',
      location:     'Platform 2 Exit',
      area:         'T. Nagar',
      city:         'Chennai',
      imageUrl:     'https://picsum.photos/seed/slot2/400/300',
      pricePerDay:  350,
      screenWidth:  1080,
      screenHeight: 1920,
      footTraffic:  8.2,
      isAvailable:  true,
      type:         'local',
    ),
    const AdSlot(
      id:           'slot_003',
      name:         'Supermarket Chain',
      location:     'Billing Counter',
      area:         'Velachery',
      city:         'Chennai',
      imageUrl:     'https://picsum.photos/seed/slot3/400/300',
      pricePerDay:  250,
      screenWidth:  1920,
      screenHeight: 1080,
      footTraffic:  5.0,
      isAvailable:  true,
      type:         'local',
    ),
    const AdSlot(
      id:           'slot_004',
      name:         'Gym & Fitness Center',
      location:     'Reception Area',
      area:         'Adyar',
      city:         'Chennai',
      imageUrl:     'https://picsum.photos/seed/slot4/400/300',
      pricePerDay:  180,
      screenWidth:  1920,
      screenHeight: 1080,
      footTraffic:  1.8,
      isAvailable:  false,
      type:         'local',
    ),
  ];
}
