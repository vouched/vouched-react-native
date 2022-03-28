# Vouched React Native Example

## Getting Started

If this is your first time implementing a React Native application, please read [how to set up your environment](https://reactnative.dev/docs/environment-setup) for the platform and mobile devices you plan to deploy to. 

### Environment

From the vouched portal, go to the [settings menu](https://app.vouched.id/account/key), and create a public key, which will be used to communicate with the Vouched service. 

Create .env in the root of the _example_ directory, replacing <PUBLIC_KEY> with your actual public key

```shell
PUBLIC_KEY=<PUBLIC_KEY>
```

### Add Vouched Assets

Navigate to your Vouched Dashboard and download the Android and iOS assets.

1. Unzip the Android assets. Create a directory at _example/android/app/src/main/assets_ and copy the asset files to that directory
2. Unzip the iOS assets and copy each file in the card_detect folder to the _example/ios/example_ directory.  Click on the Vouched project, and verify that the assets exist in the **Build Phases** tab, in the **Copy Bundle Resources** section. If not, add them using the + button in that section .

### Build

```shell

# npm
yarn install

# pods
cd ios && pod install && cd ..
```

### Run
Unfortunately, cameras are not supported in simulators so the best way to run the example is on a real device. Once your device is plugged in, follow the instructions:

**Start metro server**
```shell
yarn start
```



**Run on Android**

```shell
react-native run-android
```
Alternatively, you can start Android Studio and run and debug the app. This option may require you to reverse port in order to connect to the metro server. 
```shell
adb -s YOUR_DEVICE_ID reverse tcp:8081 tcp:8081
```

**Run on iOS**  
Start Xcode and run the app.

```shell
xed ios/example.xcworkspace
```

You will need to assign a bundle id and a develop
