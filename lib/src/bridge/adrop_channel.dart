class AdropChannel {
  static const methodChannel = "io.adrop.adrop-ads";
  static const methodBannerChannel = "$methodChannel/banner";

  static String methodBannerChannelOf(int id) => "${methodBannerChannel}_$id";
}
