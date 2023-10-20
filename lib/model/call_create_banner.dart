class CallCreateBanner {
  final String unitId;

  CallCreateBanner({required this.unitId});

  CallCreateBanner.fromJson(Map<String, dynamic> json)
      : this(
          unitId: json['unitId'] as String? ?? "",
        );

  Map<String, dynamic> toJson() => {
        'unitId': unitId,
      };
}
