import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';

class ErrorUtils {
  static String descriptionOf(AdropErrorCode? errorCode) {
    switch (errorCode) {
      case AdropErrorCode.adEmpty:
        return "There is no ad received";
      case AdropErrorCode.adLoading:
        return "waiting ad response from server after request ad";
      case AdropErrorCode.adShown:
        return "This ad was shown already";
      case AdropErrorCode.adHideForToday:
        return "You can't load ad for today";
      case AdropErrorCode.adNoFill:
        return "Unable to receive ads that meet the criteria. Please retry";
      case AdropErrorCode.inactive:
        return "There are no active advertising campaigns";
      case AdropErrorCode.adLoadDuplicate:
        return "You can't load again after ad received successfully";
      case AdropErrorCode.initialize:
        return "Initialize Adrop first before you act something";
      case AdropErrorCode.invalidUnit:
        return "Ad unit ID is not valid";
      case AdropErrorCode.internal:
        return "exception in SDK";
      case AdropErrorCode.network:
        return "The network status is unstable";
      case AdropErrorCode.notTargetCountry:
        return "Unable to use SDK when the device country is not supported.";
      case AdropErrorCode.adLandscapeUnsupported:
        return "Unable to display ad in landscape mode";
      case AdropErrorCode.undefined:
        return "undefined error";
      default:
        return "";
    }
  }
}
