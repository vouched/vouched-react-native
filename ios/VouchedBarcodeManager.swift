@objc(BarcodeCameraManager)
class BarcodeCameraManager: RCTViewManager {
    override func view() -> UIView! {
        let screenSize: CGRect = UIScreen.main.bounds
        return BarcodeCamera(frame:CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    }
    
    @objc override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc func stop(_ node: NSNumber) {
      DispatchQueue.main.async {
        let camera = self.bridge.uiManager.view(
          forReactTag: node
        ) as! BarcodeCamera
        camera.stop()
      }
    }
    
    @objc func restart(_ node: NSNumber) {
      DispatchQueue.main.async {
        let camera = self.bridge.uiManager.view(
          forReactTag: node
        ) as! BarcodeCamera
        camera.start()
      }
    }
}