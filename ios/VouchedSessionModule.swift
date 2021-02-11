import Vouched

@objc(VouchedSessionModule)
class VouchedSessionModule: NSObject {

    private static let SESSION_NOT_CONFIGURED = "SESSION_NOT_CONFIGURED"
    private static let POST_FRONT_ID_FAIL = "POST_FRONT_ID_FAIL"
    private static let POST_FACE_FAIL = "POST_FACE_FAIL"
    private static let POST_CONFIRM_FAIL = "POST_CONFIRM_FAIL"
    
    private var session: VouchedSession? = nil
    
    @objc func configure(_ apiKey: String) {
        
//        VouchedLogger.shared.configure(destination: .xcode, level: .debug)
        session = VouchedSession(apiKey: apiKey)
    }
        
    @objc func postFrontId(_ detectResult: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        var image: String? = nil
        var distanceImage: String? = nil
        
        let i = detectResult["image"]
        let di = detectResult["distanceImage"]

        if i is NSString {
            image = (i as! String)
        }
        if di is NSString {
            distanceImage = (di as! String)
        }
        
        
        let cardDetectResult = CardDetectResult(image: image, distanceImage: distanceImage, step: .postable, instruction: .none);

        do {
            let job = try session?.postFrontId(detectedCard: cardDetectResult)
            let jobString = convertJob(job!)
            resolve(jobString)
        } catch {
            reject(VouchedSessionModule.POST_FRONT_ID_FAIL, error.localizedDescription, error)
        }
        
    }
    
    @objc func postFace(_ detectResult: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        var image: String? = nil
        var distanceImage: String? = nil
        
        let i = detectResult["image"]
        let di = detectResult["userDistanceImage"]

        if i is NSString {
            image = (i as! String)
        }
        if di is NSString {
            distanceImage = (di as! String)
        }
        
        let faceDetectResult = FaceDetectResult(image: image, distanceImage: distanceImage, step: .postable, instruction: .none);

        do {
            let job = try session?.postFace(detectedFace: faceDetectResult)
            let jobString = convertJob(job!)
            resolve(jobString)
        } catch {
            reject(VouchedSessionModule.POST_FACE_FAIL, error.localizedDescription, error)
        }
        
    }
    
    @objc func confirm(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        do {
            let job = try session?.postConfirm()
            let jobString = convertJob(job!)
            resolve(jobString)
        } catch {
            reject(VouchedSessionModule.POST_CONFIRM_FAIL, error.localizedDescription, error)
        }
        
    }
    
    private func convertJob(_ job: Job) -> String? {
        do {
            let encoder = JSONEncoder();
            let jobData = try encoder.encode(job)
            let jobString = String(data: jobData, encoding: .utf8)!
            return jobString
        } catch {
            print(error)
        }
        return nil
    }
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
      return true
    }

}
 
