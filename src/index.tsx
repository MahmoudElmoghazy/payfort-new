import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-payfort' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const Payfort = NativeModules.Payfort
  ? NativeModules.Payfort
  : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    }
  );


interface Props {
  isLive: boolean;
  device_fingerprint: string;
  command: "PURCHASE" | "AUTHORIZATION",
  currency: string;
  amount: string;
  sdk_token: string;
  customer_email: string;
  merchant_reference: string;
  customer_ip: string;
  language: string;
  merchant_extra?: string;
}

export function Pay(data: Props, successCallback: () => void, failCallback: () => void) {
  return Payfort.Pay(data, successCallback, failCallback);
}
