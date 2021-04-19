

import UIKit
import VideoToolbox
import AVFoundation
import Vouched

class BaseCamera : UIView {
    
    // MARK: Storyboards Connections
    private var previewView: PreviewView!
    
    // MARK: Controllers that manage functionality
    private var cameraFeedManager: CameraFeedManager!

    private var isStopped: Bool = false

    init(frame: CGRect, position: AVCaptureDevice.Position) {
        super.init(frame: frame)

        previewView =
            PreviewView(frame: frame)
        
        cameraFeedManager = CameraFeedManager(previewView: previewView, position: position)
                
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reactSetFrame(_ frame: CGRect) {
        self.frame = frame;
        self.previewView.frame = frame;
        super.reactSetFrame(frame)
    }
    
    override func insertReactSubview(_ subview: UIView!, at atIndex: Int) {
        insertSubview(subview, at: atIndex+1)
        super.insertReactSubview(subview, at: atIndex);
    }
    
    override func removeReactSubview(_ subview: UIView!) {
        subview.removeFromSuperview()
        super.removeReactSubview(subview)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isStopped {
            return
        }
        self.layer.insertSublayer(previewView.previewLayer, at: 0)

        cameraFeedManager.delegate = self
        cameraFeedManager.checkCameraConfigurationAndStartSession()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        cameraFeedManager.stopSession()
    }
    
    @objc func stop() {
        if isStopped {
            return
        }
        isStopped = true
        cameraFeedManager.stopSession()
    }
    
    @objc func start() {
        isStopped = false
        cameraFeedManager.checkCameraConfigurationAndStartSession()
    }
}

// MARK: CameraFeedManagerDelegate Methods
extension BaseCamera: CameraFeedManagerDelegate {

    @objc func didOutput(pixelBuffer: CVPixelBuffer) {
        if isStopped {
            return
        }
    }
    
    // MARK: Session Handling Alerts
    func sessionRunTimeErrorOccured() {
        print("sessionRunTimeErrorOccured");
    }
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        print("sessionWasInterrupted: \(resumeManually)");
    }
    
    func sessionInterruptionEnded() {
        print("sessionInterruptionEnded");
    }
    
    func toStepName(_ step: Step) -> String {
        switch (step) {
        case .detected:
            return "DETECTED"
        case .postable:
            return "POSTABLE"
        case .preDetected:
            return "PRE_DETECTED"
        default:
            return ""
        }
    }
    
    func toInstructionName(_ instruction: Instruction) -> String {
        switch (instruction) {
        case .onlyOne:
            return "ONLY_ONE"
        case .moveCloser:
            return "MOVE_CLOSER"
        case .moveAway:
            return "MOVE_AWAY"
        case .holdSteady:
            return "HOLD_STEADY"
        case .openMouth:
            return "OPEN_MOUTH"
        case .closeMouth:
            return "CLOSE_MOUTH"
        case .lookForward:
            return "LOOK_FORWARD"
        case .blinkEyes:
            return "BLINK_EYES"
        default:
            return ""
        }
    }
    
}

