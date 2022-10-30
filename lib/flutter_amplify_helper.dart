library flutter_amplify_helper;

import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:get/get.dart';

class FlutterAmplifyHelper extends GetxService {
  Rx<bool> isLoggedIn = false.obs;
  Rx<bool> hasNetwork = true.obs;
  Rx<bool> hasPendingOutbox = false.obs;

  ///init function to initialize the amplify configuration
  ///must be called before using any  aws resources/categories
  Future<void> init<T extends ModelProviderInterface>({
    required String amplifyConfig,
    required T modelProvider,
  }) async {
    if (!Amplify.isConfigured) {
      Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAnalyticsPinpoint(),
        AmplifyStorageS3(),
        AmplifyAPI(modelProvider: modelProvider),
      ]);

      await Amplify.configure(amplifyConfig);
    }
  }

  ///get access token from the current user
  ///can throw an Exception if the user is not logged in
  Future<String?> getToken() async {
    dynamic cognitoSession = await Amplify.Auth.fetchAuthSession(options: CognitoSessionOptions(getAWSCredentials: true));
    return cognitoSession?.userPoolTokens?.accessToken;
  }

  ///get sub id from the current user
  ///can throw an Exception if the user is not logged in
  Future<String?> getSub() async {
    var cognitoSession = (await Amplify.Auth.fetchAuthSession(options: CognitoSessionOptions(getAWSCredentials: true))) as CognitoAuthSession;
    String? sub = cognitoSession.userSub;
    return sub;
  }
}
