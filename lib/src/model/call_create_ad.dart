class CallCreateAd {
  final String? unitId;
  final String? requestId;

  CallCreateAd({this.unitId, this.requestId});

  CallCreateAd.fromJson(Map<String, dynamic> json)
      : this(
          unitId: json['unitId'] as String? ?? '',
          requestId: json['requestId'] as String? ?? '',
        );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'unitId': unitId,
      };
}
