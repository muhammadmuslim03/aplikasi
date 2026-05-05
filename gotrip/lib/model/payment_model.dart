class PaymentModel {
  final String ticketId;  
  final int routeId;        
  final String routeName; 
  final DateTime hikingDate;
  final int totalMembers; 
  final double totalPrice;     
  final bool includeOjek;
  final int ojekCount;
  final String? proofImagePath;

  PaymentModel({
    required this.ticketId,
    required this.routeId,
    required this.routeName,
    required this.hikingDate,
    required this.totalMembers,
    required this.totalPrice,
    this.includeOjek = false,
    this.ojekCount = 0,
    this.proofImagePath,
  });

  PaymentModel copyWith({
    String? ticketId,
    int? routeId,
    String? routeName,
    DateTime? hikingDate,
    int? totalMembers,
    double? totalPrice,
    bool? includeOjek,
    int? ojekCount,
    String? proofImagePath,
  }) {
    return PaymentModel(
      ticketId: ticketId ?? this.ticketId,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      hikingDate: hikingDate ?? this.hikingDate,
      totalMembers: totalMembers ?? this.totalMembers,
      totalPrice: totalPrice ?? this.totalPrice,
      includeOjek: includeOjek ?? this.includeOjek,
      ojekCount: ojekCount ?? this.ojekCount,
      proofImagePath: proofImagePath ?? this.proofImagePath,
    );
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      ticketId: json['id'] ?? '',
      routeId: json['route_id'] ?? 0,
      routeName: json['route_name'] ?? '',
      hikingDate: DateTime.tryParse(json['hiking_date'] ?? '') ?? DateTime.now(),
      totalMembers: json['total_members'] ?? 1,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      includeOjek: json['include_ojek'] ?? false,
      ojekCount: json['ojek_count'] ?? 0,
    );
  }
}