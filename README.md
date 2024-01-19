# Vouched React Native

[![npm version](https://img.shields.io/npm/v/@vouched.id/vouched-react-native.svg?style=flat-square)](https://www.npmjs.com/package/@vouched.id/vouched-react-native)

## React Native Compatibility

Vouched React Native supports RN frameworks up to 0.72  Note: no turbo moodule or Expo integration is supported at this time

## Get Started

If this is your first time here, [Run the Example](#run-example) to get familiar.  
If you're ready to add this to your existing project, [Install the Package](#install).

## Run Example

Clone this repo and change directory to _example_

```shell
git clone https://github.com/vouched/vouched-react-native
cd vouched-react-native/example
```

Then, follow steps listed on the [example README](https://github.com/vouched/vouched-react-native/blob/master/example/README.md)

## Prerequisites

- An account with Vouched
- Your Vouched Public Key

## Install

Add the package to your existing project

```shell
yarn add @vouched.id/vouched-react-native
```

Link the package

```shell
react-native link @vouched.id/vouched-react-native
```

iOS pods are not automatically installed, so we'll need to manually install them

```shell
 cd ios && pod install
```

Ensure all [prerequisites](#prerequisites) have been met.

## Create Verification Flow

Note: Be sure to review the IDScreen, BackIDScreen and FaceScreen in 
the example app to get a sense of possible behaviors you can use in
your app's verification flow. Some IDs require processing both front 
and back sides.

1. Determine the steps needed (ID, ID + Selfie, Reverification)
2. Create one VouchedSession object that is used for the life of the IDV process. See our example application 
3. Create the Component/Screen(s) for each step. Note how the demo shares the session via useState
4. Use the appropriate Camera ([IdCamera](#idcamera) or [FaceCamera](#facecamera)) for the step.
5. Ensure [session.confirm](#post-confirm-verification) is called once verification is complete to recieve finalized job data.

## Webhook support

The React Native SDK allows a webhook URL to be specified, which is sent to the Vouched api service, and will fire upon job completion 
(as noted above, you must share a single session object during the verification flow, and call session.confirm for the callback to be triggered). To enable 
this in our example app, the callback url would be be added to the sessionParam block prior to calling initSession. See [App.js](https://github.com/vouched/vouched-react-native/blob/master/example/App.js), :

```javascript
 const sessionParams = {
  callbackURL: 'https://webhook.site/97148fec-bd05-4c1f-8b03-ab16d0e6b212',
  properties: []
};
initSession(PUBLIC_KEY, sessionParams);
```

## Reference

### VouchedSession

This class handles a user's Vouched session. It takes care of the API calls

##### Initialize a session

```javascript
const session = new VouchedSession(apiKey, sessionParams);
```
`Parameters` - String, [SessionParams](#sessionparams-object)

##### POST Front Id image

```javascript
const job = await session.postFrontId(cardDetectionResult, params);
```

`Parameters` - [CardDetectResult](#carddetectresult-object), [Params](#params-object)  
`Returns` - [Job](#job-object)

##### POST Back Id image

```javascript
const job = await session.postBackId(cardDetectionResult, params);
```

`Parameters` - [CardDetectResult](#carddetectresult-object), [Params](#params-object)
`Returns` - [Job](#job-object)

##### POST Selfie image

```javascript
const job = await session.postFace(faceDetectionResult);
```

`Parameters` - [FaceDetectResult](#facedetectresult-object)  
`Returns` - [Job](#job-object)

##### POST Re-verification

Reverification requires a job ID to match against, and photoType of "selfie" or "id",
which indicates whether to match the reverification selfie against the original selfie
or photo ID

```javascript
const authResult = await session.postReverify(
  faceDetectionResult,
  jobId,
  photoType
);
```

`Parameters` - [FaceDetectResult](#facedetectresult-object), String, String  
`Returns` - [Job](#job-object)

##### POST confirm verification

```javascript
const job = await session.confirm();
```

`Returns` - [Job](#job-object)

### VouchedUtils

Utility class

##### Extract Job Insights

```javascript
const insights = await VouchedUtils.extractInsights(job);
```

`Parameters` - [Job](#job-object)  
`Returns` - [Insight](#insight-string)[]

### IdCamera

Import and add to View

```javascript
import { VouchedIdCamera } from '@vouched.id/vouched-react-native';
...

    <VouchedIdCamera
        ref={cameraRef}
        enableDistanceCheck={true}
        onIdStream={async (cardDetectionResult) => {
            const { instruction, step } = cardDetectionResult;
            if (step === "POSTABLE") {
                cameraRef.current.stop();
                setMessage("Processing Image");
                try {
                    let job = await session.postFrontId(cardDetectionResult);
                    let insights = await VouchedUtils.extractInsights(job);
                    // optionally retry based on insights
                    // proceed to next step
                } catch (e) {
                    // handle error
                }
            } else {
                setMessage(instruction)
            }
        }}
    />
```

| Properties          |                          Type                          | Default |
| ------------------- | :----------------------------------------------------: | ------: |
| enableDistanceCheck |                        Boolean                         |   false |
| onIdStream          | Callback<[CardDetectResult](#carddetectresult-object)> |         |

##### Stop IdCamera

```javascript
cameraRef.current.stop();
```

##### Restart IdCamera

```javascript
cameraRef.current.restart();
```

### FaceCamera

Import and add to View

```javascript
import { VouchedFaceCamera } from '@vouched.id/vouched-react-native';
...

    <VouchedFaceCamera
        ref={cameraRef}
        livenessMode="DISTANCE"
        onFaceStream={async (faceDetectionResult) => {
            const { instruction, step } = faceDetectionResult;
            if (step === "POSTABLE") {
                cameraRef.current.stop();
                setMessage("Processing Image");
                try {
                    let job = await session.postFrontId(faceDetectionResult);
                    let insights = await VouchedUtils.extractInsights(job);
                    // optionally retry based on insights
                    // proceed to next step
                } catch (e) {
                    // handle error
                }
            } else {
                setMessage(instruction)
            }
        }}
    />
```

| Properties   |                          Type                          |  Default |
| ------------ | :----------------------------------------------------: | -------: |
| livenessMode |          [LivenessMode](#livenessmode-string)          | `"NONE"` |
| onFaceStream | Callback<[FaceDetectResult](#facedetectresult-object)> |          |

##### Stop FaceCamera

```javascript
cameraRef.current.stop();
```

##### Restart FaceCamera

```javascript
cameraRef.current.restart();
```

### BarcodeCamera

Import and add to View

```javascript
import { BarcodeCamera } from '@vouched.id/vouched-react-native';
...

    <VouchedBarcodeCamera
        ref={cameraRef}
        onBarcodeStream={async (barcodeResult) => {
                cameraRef.current.stop();
                setMessage("Processing Image");
                try {
                    let job = await session.postBarcode(barcodeResult);
                    let insights = await VouchedUtils.extractInsights(job);
                    // optionally retry based on insights
                    // proceed to next step
                } catch (e) {
                    // handle error
                }
            } else {
                setMessage(instruction)
            }
        }}
    />
```

| Properties   |                          Type                          |  Default |
| ------------ | :----------------------------------------------------: | -------: |
| onBarcodeStream | Callback<[BarcodeResult](#barcoderesult-object)> |          |

##### Stop FaceCamera

```javascript
cameraRef.current.stop();
```

##### Restart FaceCamera

```javascript
cameraRef.current.restart();
```

### Types

##### CardDetectResult `Object`

```javascript
{
    "instruction" : String,
    "step": String,
    "image": String?,
    "distanceImage": String?
}
```

Note: shouldn't be POSTed until the step is `"POSTABLE"`

##### FaceDetectResult `Object`

```javascript
{
    "instruction" : String,
    "step": String,
    "image": String?,
    "userDistanceImage": String?
}
```

##### BarcodeResult `Object`

```javascript
{
    "image": String?,
    "value": String?
}
```

Note: shouldn't be POSTed until the step is `"POSTABLE"`

##### Job `Object`

```javascript
{
    "result": JobResult,
    "id": String,
    "errors": JobError[],
    "token": String 
}
```

##### JobResult `Object`

```javascript
{
    "id": String?,
    "issueDate": String?,
    "country": String?,
    "confidences": JobConfidence,
    "expireDate": String?,
    "success": Boolean,
    "state": String?,
    "lastName": String?,
    "firstName": String?,
    "birthDate": String?,
    "type": String?
}
```

##### JobConfidence `Object`

```javascript
{
    "id": Number?,
    "faceMatch": Number?,
    "idGlareQuality": Number?,
    "idQuality": Number?,
    "idMatch": Number?,
    "nameMatch": Number?,
    "selfie": Number?,
    "birthDateMatch": Number?,
    "idQuality": Number?
}
```

##### JobError `Object`

```javascript
{
    "type" : String,
    "message": String
}
```

##### AuthenticateResult `Object`

```javascript
{
    "match": Number
}
```

##### SessionParams `Object`

```javascript
{
    "callbackURL": String?,
    "groupId": String?,
    "properties": Property[]?
}
```

##### Property `Object`

```javascript
{
    "name": String,
    "value": String,
}
```

##### Params `Object`

Vouched session calls send a number of parameters to the api service as the user goes through the verification process. Those paramters include images for IDs and selfies, barcode data extracted from IDs, etc. 

In some cases it is useful to add user input (sometimes referred to to as verification properties) into the parameter block, so that you can compare those values with what is actually discovered when an ID is processed by Vouched. You can pass these optional parameters, which will compare the input to what is actually found, and determine if the job is to be passed or failed bassed on those optional parameters.

Optional parameters:
```javascript
{
    "birthDate": String?,
    "email": String?,
    "firstName": String?,
    "lastName": String?,
    "phone": String?
}
```
as an example:
```javascript
const verifyParams = {
              "firstName" : "Joe",
              "lastName" : "Smith",
              "birthDate" : "07/27/1959"
            };
try {
  let job = await session.postFrontId(cardDetectionResult, verifyParams);
  ...
```

##### LivenessMode `String`

`"DISTANCE"` | `"MOUTH_MOVEMENT"` | `"BLINKING"` | `"NONE"`

##### Step `String`

`"PRE_DETECTED"` | `"DETECTED"` | `"POSTABLE"`

##### Instruction `String`

`"ONLY_ONE"` | `"MOVE_CLOSER"` | `"MOVE_AWAY"` | `"HOLD_STEADY"` | `"OPEN_MOUTH"` | `"CLOSE_MOUTH"` | `"LOOK_FORWARD"` | `"BLINK_EYES"` | `"NO_CARD"` | `"NO_FACE"`

##### Insight `String`

`"UNKNOWN"` | `"NON_GLARE"` | `"QUALITY"` | `"BRIGHTNESS"` | `"FACE"` | `"GLASSES"`
