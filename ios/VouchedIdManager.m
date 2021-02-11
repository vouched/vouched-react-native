#import "React/RCTViewManager.h"
@interface RCT_EXTERN_MODULE(IdCameraManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(enableDistanceCheck, BOOL);
RCT_EXPORT_VIEW_PROPERTY(onIdStream, RCTDirectEventBlock)
RCT_EXTERN_METHOD(
  stop:(nonnull NSNumber *)node
)
@end

