#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(VouchedUtilsModule, NSObject)
RCT_EXTERN_METHOD(extractInsights: NSDictionary
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )
@end

