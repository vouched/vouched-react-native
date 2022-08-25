#import "React/RCTViewManager.h"
@interface RCT_EXTERN_MODULE(BarcodeCameraManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(onBarcodeStream, RCTDirectEventBlock)
RCT_EXTERN_METHOD(
  stop:(nonnull NSNumber *)node
)
RCT_EXTERN_METHOD(
  restart:(nonnull NSNumber *)node
)
@end