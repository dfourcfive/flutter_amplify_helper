library flutter_amplify_helper;

import 'dart:async';

import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:get/get.dart';

class FlutterAmplifyHelper extends GetxService {
  Rx<bool> isLoggedIn = false.obs;
  Rx<bool> isSessionExpired = false.obs;

  Rx<bool> hasNetwork = true.obs;
  Rx<bool> hasPendingOutbox = false.obs;

  ///init function to initialize the amplify configuration
  ///must be called before using any  aws resources/categories
  ///use true for `useDatastore` if you want to use datastore instead of API
  Future<void> init<T extends ModelProviderInterface>({
    required String amplifyConfig,
    required T modelProvider,
    bool enableDatastore = false,
    dynamic Function(AmplifyException)? errorHandler,
    ConflictResolutionDecision Function(ConflictData)? conflictHandler,
    List<DataStoreSyncExpression> syncExpressions = const [],
    int? syncInterval,
    int? syncMaxRecords,
    int? syncPageSize,
    AuthModeStrategy authModeStrategy = AuthModeStrategy.defaultStrategy,
  }) async {
    if (!Amplify.isConfigured) {
      Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAnalyticsPinpoint(),
        AmplifyStorageS3(),
        enableDatastore
            ? AmplifyDataStore(
                modelProvider: modelProvider,
                errorHandler: errorHandler,
                conflictHandler: conflictHandler,
                syncExpressions: syncExpressions,
                syncInterval: syncInterval,
                syncMaxRecords: syncMaxRecords,
                syncPageSize: syncPageSize,
                authModeStrategy: authModeStrategy)
            : AmplifyAPI(modelProvider: modelProvider),
      ]);

      await Amplify.configure(amplifyConfig);
    }
  }

  ///a function that returns stream of Auth category changes
  Future<StreamSubscription<HubEvent>> listenAuthChanges() async {
    return Amplify.Hub.listen([HubChannel.Auth], (event) {
      switch (event.eventName) {
        case 'SIGNED_IN':
          isLoggedIn.value = true;
          isSessionExpired.value = false;
          break;
        case 'SIGNED_OUT':
          isLoggedIn.value = false;
          isSessionExpired.value = true;

          break;
        case 'SESSION_EXPIRED':
          isLoggedIn.value = false;
          isSessionExpired.value = true;

          break;
        case 'USER_DELETED':
          isLoggedIn.value = false;
          isSessionExpired.value = true;
          break;
      }
    });
  }

  ///a function that returns stream of Datastore category changes
  Future<StreamSubscription<HubEvent>?> listenDatastoreChanges() async {
    return Amplify.Hub.listen([HubChannel.DataStore], (event) {
      if (event.eventName == 'networkStatus') {
        final status = event.payload as NetworkStatusEvent?;
        hasNetwork.value = status?.active ?? false;
      }
    });
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
