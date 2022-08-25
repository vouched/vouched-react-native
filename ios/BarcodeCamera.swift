

import UIKit
import VideoToolbox
import VouchedCore

class BarcodeCamera : BaseCamera {
    
    @objc var onBarcodeStream: RCTDirectEventBlock?
    
    private var barcodeDetect: BarcodeDetect!
    
    init(frame: CGRect) {
        super.init(frame: frame, position: .back)
        barcodeDetect = BarcodeDetect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didOutput(sampleBuffer: CMSampleBuffer) {
        super.didOutput(sampleBuffer: sampleBuffer)
        runModel(onSampleBuffer: sampleBuffer)
    }
    
    @objc override func start() {
        //barcodeDetect = BarcodeDetect()
        super.start()
    }
    
    /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
     */
    @objc func runModel(onSampleBuffer sampleBuffer: CMSampleBuffer) {
        do {
            let barcodeResult = try barcodeDetect.detect(sampleBuffer)
            if let barcodeResult = barcodeResult as? BarcodeResult {
                let result = String(data: try JSONEncoder().encode(barcodeResult), encoding: .utf8)
                onBarcodeStream!(["result": result!]);
            }
        }
        catch {
            NSLog("An error occured during barcode detection: \(error)")
        }
            
    }

}

