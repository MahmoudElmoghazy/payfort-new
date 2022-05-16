#import "Payfort.h"

@implementation Payfort

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

@end
