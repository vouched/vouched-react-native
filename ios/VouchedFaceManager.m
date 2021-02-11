#import "React/RCTViewManager.h"
@interface RCT_EXTERN_MODULE(FaceCameraManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(livenessMode, NSString);
RCT_EXPORT_VIEW_PROPERTY(onFaceStream, RCTDirectEventBlock)
RCT_EXTERN_METHOD(
  stop:(nonnull NSNumber *)node
)
@end
