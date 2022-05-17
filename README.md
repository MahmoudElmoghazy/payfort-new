<p align="left">
<a href="https://www.npmjs.com/package/@logisticinfotech/react-native-payfort-sdk"><img alt="npm version" src="https://img.shields.io/badge/npm-v1.0.15-green.svg"></a>
<a href="https://www.npmjs.com/package/@logisticinfotech/react-native-payfort-sdk"><img src="https://img.shields.io/badge/downloads-%3E1K-yellow.svg"></a>
<a href="https://www.npmjs.com/package/@logisticinfotech/react-native-payfort-sdk"<><img src="https://img.shields.io/badge/license-MIT-orange.svg"></a>
</p>

# @logisticinfotech/react-native-payfort-sdk

## Getting started

`$ npm install @logisticinfotech/react-native-payfort-sdk --save`

### Mostly automatic installation

`$ react-native link @logisticinfotech/react-native-payfort-sdk`

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `@logisticinfotech/react-native-payfort-sdk` and add `PayFort.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libPayFort.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`

- Add `import com.RNPayfortSdk.RNPayfortSdkPackage;` to the imports at the top of the file
- Add `new RNPayfortSdkPackage()` to the list returned by the `getPackages()` method

2. Append the following lines to `android/settings.gradle`:

   ```
   include ':@logisticinfotech/react-native-payfort-sdk'
   project(':@logisticinfotech/react-native-payfort-sdk').projectDir = new File(rootProject.projectDir,     '../node_modules/@logisticinfotech/react-native-payfort-sdk/android')
   ```

3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:

   ```
     compile project(':@logisticinfotech/react-native-payfort-sdk')
   ```

## Steps to follow before use

### Android

Nothing just run the app.

### iOS

1. Download PayFort SDK Module file from [here](https://drive.google.com/file/d/1WIaV-73AdKiHg1upi36CrJMhJ48OTTUt/view?usp=sharing).
2. Extract PayFortSDK_2.3.zip and open & copy PayFortSDK.bundle & PayFortSDK.framework to iOS directory of your project.
3. Replace `#import <PayFortSDK/PayFortView.h>` to `#import "PayFortView.h"` and replace `#import <PayFortSDK/PayFortController.h>` to `#import "PayFortController.h"` in PayFortSDK.framework → Headers → PayFortSDK.h
4. Copy path of PayFortSDK.h file from PayFortSDK.framework → Headers and add that path in Pods → Development Pods → react-native-payfort-sdk → PayFort.h as shown in screenshot
   ![](Screenshot.png)
5. Add `pod 'JVFloatLabeledTextField'` in the pod file.
6. open iOS folder in terminal and run command "pod install" .
7. Open your project on xcode, navigate to build phases → Copy Bundle Resources → Add PayFortView2.xib from `node_modules/@logisticinfotech/react-native-payfort-sdk/ios/PayFortView2.xib`

## Usage

```javascript
import { RNPayFort } from "@logisticinfotech/react-native-payfort-sdk/PayFortSDK/PayFortSDK";

onPay = async () => {
  await RNPayFort({
    command: "PURCHASE",
    access_code: "xxxxxxxxxxxxxxxxxx",
    merchant_identifier: "xxxxxxxxxx",
    sha_request_phrase: "xxxxxxxxxxxxxxxxxx",
    amount: 100,
    currencyType: "SAR",
    language: "en",
    email: "naishadh@logisticinfotech.co.in",
    testing: true,
  })
    .then((response) => {
      console.log(response);
    })
    .catch((error) => {
      console.log(error);
    });
};
```

##### Usage with sdk_token provided

```javascript
import {
  getPayFortDeviceId,
  RNPayFort,
} from "@logisticinfotech/react-native-payfort-sdk/PayFortSDK/PayFortSDK";

getDeviceToken = async () => {
  getPayFortDeviceId().then(async (deviceId) => {
    await Axios.post("YOUR_WEB_URL_FOR_SDK_TOKEN_GENERATION", {
      deviceId: deviceId,
    })
      .then((response) => {
        this.setState({ sdk_token: response.data.sdk_token }, () => {
          this.onPay();
        });
      })
      .catch((error) => {
        console.log(error);
      });
  });
};

onPay = async () => {
  await RNPayFort({
    command: "PURCHASE",
    access_code: "xxxxxxxxxxxxxxxxxx",
    merchant_identifier: "xxxxxxxxxx",
    sha_request_phrase: "xxxxxxxxxxxxxxxxxx",
    amount: 100,
    currencyType: "SAR",
    language: "en",
    email: "naishadh@logisticinfotech.co.in",
    testing: true,
    sdk_token: this.state.sdk_token,
  })
    .then((response) => {
      console.log(response);
    })
    .catch((error) => {
      console.log(error);
    });
};