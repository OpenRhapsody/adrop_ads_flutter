enum AdropBannerSize {
  h50("H50"),
  h80("H80"),
  h100("H100");

  final String id;

  const AdropBannerSize(this.id);

  factory AdropBannerSize.getById(String id) {
    return AdropBannerSize.values.firstWhere(
      (value) => value.id == id,
      orElse: () => AdropBannerSize.h50,
    );
  }
}
