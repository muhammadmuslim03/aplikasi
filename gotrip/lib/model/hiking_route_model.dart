class HikingRouteModel {
  final int id;
  final String routeName;
  final String description;
  final bool isOpen;

  HikingRouteModel({
    required this.id,
    required this.routeName,
    required this.description,
    required this.isOpen,
  });

  factory HikingRouteModel.fromJson(Map<String, dynamic> json) {
    return HikingRouteModel(
      id: json['id'] ?? 0,
      routeName: json['route_name'] ?? '',
      description: json['description'] ?? '',
      isOpen: json['is_open'] ?? false,
    );
  }
}