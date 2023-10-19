class AdropChannel {
  static const methodChannel = "com.openrhapsody.adrop-ads";
  static const methodBannerChannel = "$methodChannel/banner";

  static String methodBannerChannelOf(int id) => "${methodBannerChannel}_$id";
}
