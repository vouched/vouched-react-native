import UIKit
import VideoToolbox
import VouchedCore

class IdCamera : BaseCamera {
    
    @objc var onIdStream: RCTDirectEventBlock?
    @objc var enableDistanceCheck: Bool = false
    
    private var cardDetect: CardDetect!
    private var currentEnableDistanceCheck: Bool = false
    
    init(frame: CGRect) {
        super.init(frame: frame, position: .back)
                
        cardDetect = CardDetect(options: CardDetectOptionsBuilder().withEnableDistanceCheck(currentEnableDistanceCheck).build())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didOutput(sampleBuffer: CMSampleBuffer) {
        super.didOutput(sampleBuffer: sampleBuffer)
        runModel(onSampleBuffer: sampleBuffer)
    }
    
    @objc override func start() {
        cardDetect = CardDetect(options: CardDetectOptionsBuilder().withEnableDistanceCheck(currentEnableDistanceCheck).build())
        super.start()
    }
    
    /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
     */
    @objc func runModel(onSampleBuffer sampleBuffer: CMSampleBuffer) {

        if currentEnableDistanceCheck != enableDistanceCheck {
            currentEnableDistanceCheck = enableDistanceCheck
            cardDetect = CardDetect(options: CardDetectOptionsBuilder().withEnableDistanceCheck(currentEnableDistanceCheck).build())
        }
        
        do {
            let cardDetectResult = try cardDetect.detect(sampleBuffer)
            if let cardDetectResult = cardDetectResult as? CardDetectResult {
                let result = String(data: try JSONEncoder().encode(cardDetectResult), encoding: .utf8)
                onIdStream!([
                                "result": result!,
                                "instruction" : toInstructionName(cardDetectResult.instruction),
                                "step": toStepName(cardDetectResult.step)]
                );
                if cardDetectResult.step == Step.postable {
                    sleep(1)
                }
            } else {
                onIdStream!(["result": nil, "instruction" : "NO_CARD", "step": "PRE_DETECTED"])
            }
        }
        catch {
            NSLog("An error occured during id detection: \(error)")
        }
        
    }

}

