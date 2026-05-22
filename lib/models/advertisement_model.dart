enum AdStatusType { pending, approved, rejected, live }

extension AdStatusTypeExt on AdStatusType {
  String get label {
    switch (this) {
      case AdStatusType.pending:
        return 'Pending Approval';
      case AdStatusType.approved:
        return 'Approved';
      case AdStatusType.rejected:
        return 'Rejected';
      case AdStatusType.live:
        return 'Live';
    }
  }

  static AdStatusType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
        return AdStatusType.approved;
      case 'rejected':
        return AdStatusType.rejected;
      case 'live':
        return AdStatusType.live;
      default:
        return AdStatusType.pending;
    }
  }
}

class Advertisement {
  final String id;
  final String title;
  final String description;
  final String mediaUrl;
  final String mediaType; // 'image' | 'video'
  final String slotId;
  final String slotName;
  final String slotLocation;
  final int durationDays;
  final double amountPaid;
  final AdStatusType status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? rejectionReason;

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
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        mediaUrl: json['media_url'] as String? ?? '',
        mediaType: json['media_type'] as String? ?? 'image',
        slotId: json['slot_id'] as String? ?? '',
        slotName: json['slot_name'] as String? ?? '',
        slotLocation: json['slot_location'] as String? ?? '',
        durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
        amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
        status:
            AdStatusTypeExt.fromString(json['status'] as String? ?? 'pending'),
        createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
        expiresAt: _parseDate(json['expires_at']),
        rejectionReason: json['rejection_reason'] as String?,
      );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool get isImage => mediaType == 'image';
  bool get isVideo => mediaType == 'video';
}
