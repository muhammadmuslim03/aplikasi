class HikingRouteModel {
  final int id;
  final String routeName;
  final String description;
  final bool isOpen;
  final String closedReason;

  HikingRouteModel({
    required this.id,
    required this.routeName,
    required this.description,
    required this.isOpen,
    required this.closedReason,
  });

  factory HikingRouteModel.fromJson(Map<String, dynamic> json) {
    return HikingRouteModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      routeName: json['route_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isOpen: json['is_open'] == true || json['is_open']?.toString() == 'true',
      closedReason: json['closed_reason']?.toString() ?? '',
    );
  }
}
