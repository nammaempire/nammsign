enum AdStatusType { pending, approved, rejected, live }

extension AdStatusTypeExt on AdStatusType {
  String get label {
    switch (this) {
      case AdStatusType.pending:  return 'Pending Approval';
      case AdStatusType.approved: return 'Approved';
      case AdStatusType.rejected: return 'Rejected';
      case AdStatusType.live:     return 'Live';
    }
  }

  static AdStatusType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'approved': return AdStatusType.approved;
      case 'rejected': return AdStatusType.rejected;
      case 'live':     return AdStatusType.live;
      default:         return AdStatusType.pending;
    }
  }
}

class Advertisement {
  final String        id;
  final String        title;
  final String        description;
  final String        mediaUrl;
  final String        mediaType;    // 'image' | 'video'
  final String        slotId;
  final String        slotName;
  final String        slotLocation;
  final int           durationDays;
  final double        amountPaid;
  final AdStatusType  status;
  final DateTime      createdAt;
  final DateTime?     expiresAt;
  final String?       rejectionReason;

  const Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.mediaType,
    required this.slotId,
    required this.slotName,
    required this.slotLocation,
    required this.durationDays,
    required this.amountPaid,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.rejectionReason,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) => Advertisement(
        id:              json['id']              as String,
        title:           json['title']           as String,
        description:     json['description']     as String,
        mediaUrl:        json['media_url']       as String,
        mediaType:       json['media_type']      as String,
        slotId:          json['slot_id']         as String,
        slotName:        json['slot_name']       as String,
        slotLocation:    json['slot_location']   as String,
        durationDays:    json['duration_days']   as int,
        amountPaid:      (json['amount_paid'] as num).toDouble(),
        status:          AdStatusTypeExt.fromString(json['status'] as String),
        createdAt:       DateTime.parse(json['created_at'] as String),
        expiresAt:       json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        rejectionReason: json['rejection_reason'] as String?,
      );

  bool get isImage => mediaType == 'image';
  bool get isVideo => mediaType == 'video';

  // ── Mock Data ─────────────────────────────────────────────────────────────
  static List<Advertisement> mockAds = [
    Advertisement(
      id:           'ad_001',
      title:        'Summer Sale – 50% Off',
      description:  'Huge discounts on all electronics this summer!',
      mediaUrl:     'https://picsum.photos/seed/ad1/800/450',
      mediaType:    'image',
      slotId:       'slot_001',
      slotName:     'City Centre Mall',
      slotLocation: 'Anna Nagar, Chennai',
      durationDays: 7,
      amountPaid:   3500,
      status:       AdStatusType.live,
      createdAt:    DateTime.now().subtract(const Duration(days: 5)),
      expiresAt:    DateTime.now().add(const Duration(days: 2)),
    ),
    Advertisement(
      id:           'ad_002',
      title:        'New Restaurant Opening',
      description:  'Grand opening – free desserts for first 100 customers!',
      mediaUrl:     'https://picsum.photos/seed/ad2/800/450',
      mediaType:    'image',
      slotId:       'slot_002',
      slotName:     'Metro Station',
      slotLocation: 'T. Nagar, Chennai',
      durationDays: 3,
      amountPaid:   1050,
      status:       AdStatusType.pending,
      createdAt:    DateTime.now().subtract(const Duration(days: 1)),
    ),
    Advertisement(
      id:           'ad_003',
      title:        'Fitness Boot Camp',
      description:  'Join our 30-day fitness challenge. Limited slots!',
      mediaUrl:     'https://picsum.photos/seed/ad3/800/450',
      mediaType:    'image',
      slotId:       'slot_003',
      slotName:     'Supermarket Chain',
      slotLocation: 'Velachery, Chennai',
      durationDays: 14,
      amountPaid:   3500,
      status:       AdStatusType.approved,
      createdAt:    DateTime.now().subtract(const Duration(days: 3)),
      expiresAt:    DateTime.now().add(const Duration(days: 11)),
    ),
  ];
}
