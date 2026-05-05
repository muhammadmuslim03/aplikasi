class TicketModel {
  final String id;
  final int userId;
  final int routeId;
  final String? routeName;
  final DateTime bookingDate;
  final DateTime hikingDate;
  final int totalMembers;
  final double totalPrice;
  final String status;
  final String? qrCodeData;

  final bool includeOjek;
  final int ojekCount;
  final String? rejectNote;

  TicketModel({
    required this.id,
    required this.userId,
    required this.routeId,
    this.routeName,
    required this.bookingDate,
    required this.hikingDate,
    required this.totalMembers,
    required this.totalPrice,
    required this.status,
    this.qrCodeData,
    this.includeOjek = false,
    this.ojekCount = 0,
    this.rejectNote,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString() ?? '', // 🔥 WAJIB STRING
      userId: json['user_id'] ?? 0,
      routeId: json['route_id'] ?? 0,
      routeName: json['route_name'],
      bookingDate:
          DateTime.tryParse(json['booking_date'] ?? '') ?? DateTime.now(),
      hikingDate:
          DateTime.tryParse(json['hiking_date'] ?? '') ?? DateTime.now(),
      totalMembers: json['total_members'] ?? 1,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      qrCodeData: json['qr_code_data'],
      includeOjek: json['include_ojek'] ?? false,
      ojekCount: json['ojek_count'] ?? 0,
      rejectNote: json['reject_note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'hiking_date': hikingDate.toIso8601String().split('T').first,
      'total_members': totalMembers,
      'total_price': totalPrice,
    };
  }
}