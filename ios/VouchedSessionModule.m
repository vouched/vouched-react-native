#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(VouchedSessionModule, NSObject)
RCT_EXTERN_METHOD(configure: NSString
                  sessionParams: NSDictionary)
RCT_EXTERN_METHOD(postFrontId: NSDictionary
                  parameters: NSDictionary
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )
RCT_EXTERN_METHOD(postBackId: NSDictionary
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )
RCT_EXTERN_METHOD(postBarcode: NSDictionary
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )
RCT_EXTERN_METHOD(postFace: NSDictionary
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )
RCT_EXTERN_METHOD(confirm: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )
RCT_EXTERN_METHOD(postReverify: NSDictionary
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  )
@end
