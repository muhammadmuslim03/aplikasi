double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

class TicketPaymentModel {
  final String id;
  final String ticketId;
  final String provider;
  final String paymentMethod;
  final double amount;
  final String status;
  final String? paymentUrl;
  final String? snapToken;
  final String? vaNumber;
  final String? qrString;
  final DateTime? expiredAt;
  final DateTime? paidAt;

  const TicketPaymentModel({
    required this.id,
    required this.ticketId,
    required this.provider,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    this.paymentUrl,
    this.snapToken,
    this.vaNumber,
    this.qrString,
    this.expiredAt,
    this.paidAt,
  });

  factory TicketPaymentModel.fromJson(Map<String, dynamic> json) {
    return TicketPaymentModel(
      id: (json['id'] ?? json['payment_id'] ?? '').toString(),
      ticketId: (json['ticket_id'] ?? json['booking_id'] ?? '').toString(),
      provider: (json['provider'] ?? '').toString(),
      paymentMethod: (json['payment_method'] ?? json['method'] ?? '')
          .toString(),
      amount: _toDouble(json['amount'] ?? json['total_price']),
      status: (json['status'] ?? 'pending').toString(),
      paymentUrl: json['payment_url']?.toString(),
      snapToken: json['snap_token']?.toString(),
      vaNumber: json['va_number']?.toString(),
      qrString: json['qr_string']?.toString(),
      expiredAt: DateTime.tryParse(json['expired_at']?.toString() ?? ''),
      paidAt: DateTime.tryParse(json['paid_at']?.toString() ?? ''),
    );
  }
}

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
  final TicketPaymentModel? payment;

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
    this.payment,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final rawPayment = json['payment'];

    return TicketModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? 0,
      routeId: json['route_id'] ?? 0,
      routeName: json['route_name'],
      bookingDate:
          DateTime.tryParse(json['booking_date'] ?? '') ?? DateTime.now(),
      hikingDate:
          DateTime.tryParse(json['hiking_date'] ?? '') ?? DateTime.now(),
      totalMembers: json['total_members'] ?? 1,
      totalPrice: _toDouble(json['total_price']),
      status: json['status'] ?? 'pending',
      qrCodeData: json['qr_code_data'],
      includeOjek: json['include_ojek'] ?? false,
      ojekCount: json['ojek_count'] ?? 0,
      rejectNote: json['reject_note'],
      payment: rawPayment is Map<String, dynamic>
          ? TicketPaymentModel.fromJson(rawPayment)
          : null,
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
