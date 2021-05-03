# Vouched React Native Example

## Getting Started

### Environment

Create .env

```shell
PUBLIC_KEY=
```

### Add Vouched Assets

Navigate to your Vouched Dashboard and download the Android and iOS assets.

1. Unzip the Android assets and copy the assets directory to _android/app/src/main/assets/_
2. Unzip the iOS assets and copy each file to _ios/example_. Double check **Copy Bundle Resources**

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
OR start Android Studio and run the app. This option may require you to reverse port in order to connect to the metro server. 
```shell
adb -s YOUR_DEVICE_ID reverse tcp:8081 tcp:8081
```

**Run on iOS**  
Start Xcode and run the app.
```shell
xed ios/example.xcworkspace
```
