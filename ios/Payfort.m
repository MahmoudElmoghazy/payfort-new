#import "Payfort.h"

@implementation Payfort

NSString *sdk_token;
NSString *_merchant_reference;
NSDictionary *applePayRequestDict;
RCTResponseSenderBlock successCallbackApplePay;
RCTResponseSenderBlock errorCallbackApplePay;
BOOL isApplePaymentDidPayment = FALSE;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(Pay
                  : (NSString *)strData successCallback
                  : (RCTResponseSenderBlock)successCallback errorCallback
                  : (RCTResponseSenderBlock)errorCallback) {

  NSDictionary *input = [self convertToDictonary:strData];
  NSNumber *isLive = [input objectForKey:@"isLive"];

  NSNumber *command = [input objectForKey:@"command"];
  NSNumber *sdk_token = [input objectForKey:@"sdk_token"];
  NSNumber *merchant_reference = [input objectForKey:@"merchant_reference"];
  NSNumber *merchant_extra = [input objectForKey:@"merchant_extra"];
  NSNumber *customer_email = [input objectForKey:@"customer_email"];
  NSNumber *currency = [input objectForKey:@"currency"];
  NSNumber *language = [input objectForKey:@"language"];
  NSNumber *amount = [input objectForKey:@"amount"];
  NSNumber *device_fingerprint = [input objectForKey:@"device_fingerprint"];
  NSNumber *customer_ip = [input objectForKey:@"customer_ip"];

  PayFortController *PayFort = [[PayFortController alloc]
      initWithEnviroment:[isLive boolValue] ? PayFortEnviromentProduction
                                            : PayFortEnviromentSandBox];

  // [PayFort setPayFortCustomViewNib:@"CustomPayFortView"];

  NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
  [request setValue:command forKey:@"command"];
  [request setValue:sdk_token forKey:@"sdk_token"];
  [request setValue:merchant_reference forKey:@"merchant_reference"];
  [request setValue:merchant_extra forKey:@"merchant_extra"];
  [request setValue:customer_email forKey:@"customer_email"];
  [request setValue:language forKey:@"language"];
  [request setValue:currency forKey:@"currency"];
  [request setValue:amount forKey:@"amount"];
  [request setValue:customer_ip forKey:@"customer_ip"];
  [request setValue:device_fingerprint forKey:@"device_fingerprint"];

  PayFort.isShowResponsePage = true;
  PayFort.presentAsDefault = true;

      dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *nav =
            (UIViewController *)[UIApplication sharedApplication]
                .delegate.window.rootViewController;

        [PayFort callPayFortWithRequest:request
            currentViewController:nav
            success:^(NSDictionary *requestDic, NSDictionary *responeDic) {
              PayFort.hideLoading = true;

              NSLog(@"Success");
              NSLog(@"responeDic=%@", responeDic);
              successCallback(@[ responeDic ]);
            }
            canceled:^(NSDictionary *requestDic, NSDictionary *responeDic) {
              PayFort.hideLoading = true;

              NSLog(@"Canceled");
              NSLog(@"responeDic=%@", responeDic);
              errorCallback(@[ responeDic ]);
            }
            faild:^(NSDictionary *requestDic, NSDictionary *responeDic,
                    NSString *message) {
              PayFort.hideLoading = true;

              NSLog(@"Faild");
              NSLog(@"responeDic=%@", responeDic);
              errorCallback(@[ responeDic ]);
            }];
      });

}

- (NSDictionary *)convertToDictonary:(NSString *)strData {
  NSData *data = [strData dataUsingEncoding:NSUTF8StringEncoding];
  id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  return json;
}

RCT_EXPORT_METHOD(getDeviceId : (RCTResponseSenderBlock)successCallback) {
  PayFortController *PayFort =
      [[PayFortController alloc] initWithEnviroment:PayFortEnviromentSandBox];
  //    NSString *UUID = [[NSUUID UUID] UUIDString];
  successCallback(@[ PayFort.getUDID ]);
}

/// apple pay
RCT_EXPORT_METHOD(PayWithApplePay:(NSString *)strData successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseSenderBlock)errorCallback)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        applePayRequestDict = [self convertToDictonary:strData];
        _merchant_reference = [applePayRequestDict objectForKey:@"merchant_reference"];
        
        sdk_token = [applePayRequestDict objectForKey:@"sdk_token"];
        NSLog(@"sdk_token: %@",sdk_token);
        
        if (_merchant_reference == nil)
        {
            _merchant_reference = [NSString stringWithFormat:@"%d",arc4random()];
        }
        
//        if (sdk_token == nil || sdk_token == (id)[NSNull null]) {
//
//            [self getSDKToken:applePayRequestDict completionHandler:^(bool Success) {
//                if (Success)
//                {
//                    [self applePayWithPayfort:errorCallback andSuccessCallbackApplePay:successCallback];
//                }
//
//            }];
//        } else {
        [self applePayWithPayfort:errorCallback andSuccessCallbackApplePay:successCallback];
//        }
    });
}

- (void)applePayWithPayfort:(RCTResponseSenderBlock )errorCallback andSuccessCallbackApplePay:(RCTResponseSenderBlock )successCallback
{
    PKPaymentRequest *request = [PKPaymentRequest new];
    request.merchantIdentifier = [applePayRequestDict objectForKey:@"apple_pay_merchant_identifier"];
    if (@available(iOS 12.1.1, *)) {
        request.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkMada];
    } else {
        request.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    }
    request.merchantCapabilities = PKMerchantCapability3DS;
    
    request.countryCode = @"SA";
    request.currencyCode =  [applePayRequestDict objectForKey:@"currencyType"];
            
    NSMutableArray *arrSummaryItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary *objItem in [applePayRequestDict objectForKey:@"arrItem"])
    {

        NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithMantissa:strtoull([[objItem valueForKey:@"price"] UTF8String], NULL, 0) exponent:-2 isNegative:NO];
        
        
        [arrSummaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:[objItem valueForKey:@"productName"] amount:price]];
    }
    
    request.paymentSummaryItems = [arrSummaryItems copy];
    PKPaymentAuthorizationViewController *applePayController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    applePayController.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *nav =  (UIViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
        [nav presentViewController:applePayController animated:YES completion:nil];
    });
    
    successCallbackApplePay = successCallback;
    errorCallbackApplePay = errorCallback;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    __block UIBackgroundTaskIdentifier backgroundTask;
    backgroundTask =
    [application beginBackgroundTaskWithExpirationHandler: ^ {
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid; }];
}


#pragma mark - PKPaymentAuthorizationViewControllerDelegate


-(void)paymentAuthorizationViewController:
(PKPaymentAuthorizationViewController *)controller
                      didAuthorizePayment:(PKPayment *)payment
                               completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    BOOL asyncSuccessful = payment.token.paymentData.length != 0;
    NSLog(@"%@", payment);

    if(asyncSuccessful) {
    
        @try {
    
            NSNumber *isLive = [applePayRequestDict objectForKey:@"isLive"];
    
            NSNumber *command = [applePayRequestDict objectForKey:@"command"];
            NSNumber *sdk_token = [applePayRequestDict objectForKey:@"sdk_token"];
            NSNumber *merchant_reference = [applePayRequestDict objectForKey:@"merchant_reference"];
            NSNumber *merchant_extra = [applePayRequestDict objectForKey:@"merchant_extra"];
            NSNumber *customer_email = [applePayRequestDict objectForKey:@"customer_email"];
            NSNumber *currency = [applePayRequestDict objectForKey:@"currency"];
            NSNumber *language = [applePayRequestDict objectForKey:@"language"];
            NSNumber *amount = [applePayRequestDict objectForKey:@"amount"];
            NSNumber *device_fingerprint = [applePayRequestDict objectForKey:@"device_fingerprint"];
            NSNumber *customer_ip = [applePayRequestDict objectForKey:@"customer_ip"];
    
            PayFortController *PayFort = [[PayFortController alloc]
                initWithEnviroment:[isLive boolValue] ? PayFortEnviromentProduction
                                                      : PayFortEnviromentSandBox];
    
            NSMutableDictionary *request = [[NSMutableDictionary alloc]init];
            [request setValue:command forKey:@"command"];
            [request setValue:sdk_token forKey:@"sdk_token"];
            [request setValue:merchant_reference forKey:@"merchant_reference"];
            [request setValue:merchant_extra forKey:@"merchant_extra"];
            [request setValue:customer_email forKey:@"customer_email"];
            [request setValue:language forKey:@"language"];
            [request setValue:currency forKey:@"currency"];
            [request setValue:amount forKey:@"amount"];
            [request setValue:customer_ip forKey:@"customer_ip"];
            [request setValue:device_fingerprint forKey:@"device_fingerprint"];
            [request setValue:@"APPLE_PAY" forKey:@"digital_wallet"];
    
            NSLog(@"request-applePay%@", request);
    
            UIViewController *nav =  (UIViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    
            [PayFort callPayFortForApplePayWithRequest:request
                        applePayPayment:payment
                  currentViewController:nav
                        success:^(NSDictionary *requestDic, NSDictionary *responeDic) {
                            isApplePaymentDidPayment = TRUE;
                            successCallbackApplePay(@[responeDic]);
                            completion(PKPaymentAuthorizationStatusSuccess);
    
                        }
                          faild:^(NSDictionary *requestDic, NSDictionary *responeDic, NSString *message) {
                            isApplePaymentDidPayment = TRUE;
                            errorCallbackApplePay(@[responeDic]);
                            completion(PKPaymentAuthorizationStatusFailure);
                    }
    
                ];
        } @catch (NSException *exception) {
            NSLog(@"exception: ", exception);
        }
        
    }
}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
    {
        if(!isApplePaymentDidPayment)
        {
            errorCallbackApplePay(@[applePayRequestDict]);
        }
        [controller dismissViewControllerAnimated:true completion:nil];
    }


@end
