
a small class helper (Getx service) that facilitate and speed up the develoepment mobile apps with amazon web services

## Features
-  To get sub id from the current user :

```dart
FlutterAmplifyHelper().getSub();
```

-  To get access token from the current user use the method below :

```dart
FlutterAmplifyHelper().getToken();
```
## Getting started

- To get started with flutter aws please follow the official documents from the link below : 

https://docs.amplify.aws/start/q/integration/flutter/

## Usage

Install the package and import the file ``FlutterAmplifyHelper`` 

```dart
  await Get.putAsync<FlutterAmplifyHelper>(
      () => FlutterAmplifyHelper().init<ModelProvider>(amplifyConfig: amplifyconfig, modelProvider: ModelProvider.instance));;
```

## Additional information

All pull requests are welcome
