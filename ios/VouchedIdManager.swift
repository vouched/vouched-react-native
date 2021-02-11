
@objc(IdCameraManager)
class IdCameraManager: RCTViewManager {
    override func view() -> UIView! {
        let screenSize: CGRect = UIScreen.main.bounds
        return IdCamera(frame:CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    }
    @objc override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc func stop(_ node: NSNumber) {
      DispatchQueue.main.async {
        let camera = self.bridge.uiManager.view(
          forReactTag: node
        ) as! IdCamera
        camera.stop()
      }
    }

}
