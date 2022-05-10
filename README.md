# react-native-payfort

React native payfort

## Installation

```sh
npm install react-native-payfort
```

## Usage

```js
import { Pay } from "react-native-payfort";

// ...

const result = Pay({
  isLive: true | false,
  device_fingerprint: "{Device UDID}";
  command: "PURCHASE" | "AUTHORIZATION",
  currency: "{SAR | USD | etc...}";
  amount: "{1000}";
  sdk_token: "{SDK token} you can get it from api request check the example";
  customer_email: "{customer email}";
  merchant_reference: "{Order id}";
  customer_ip: "{User customer IP}";
  language: "{en | ar}";
  merchant_extra?: "{This is order...}";
})
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
