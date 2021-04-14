import Vouched

@objc(VouchedSessionModule)
class VouchedSessionModule: NSObject {

    private static let SESSION_NOT_CONFIGURED = "SESSION_NOT_CONFIGURED"
    private static let POST_FRONT_ID_FAIL = "POST_FRONT_ID_FAIL"
    private static let POST_FACE_FAIL = "POST_FACE_FAIL"
    private static let POST_CONFIRM_FAIL = "POST_CONFIRM_FAIL"
    private static let POST_AUTHENTICATE_FAIL = "POST_AUTHENTICATE_FAIL"

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
            let jobString = convertObjToString(job!)
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
            let jobString = convertObjToString(job!)
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
            let jobString = convertObjToString(job!)
            resolve(jobString)
        } catch {
            reject(VouchedSessionModule.POST_CONFIRM_FAIL, error.localizedDescription, error)
        }
        
    }
    
    @objc func postAuthenticate(_ authRequest: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        var image: String? = nil
        var jobId: String? = nil
        var matchId: Bool? = nil

        let i = authRequest["image"]
        let j = authRequest["jobId"]
        let m = authRequest["matchId"]

        if i is NSString {
            image = (i as! String)
        }
        if j is NSString {
            jobId = (j as! String)
        }
        if m is NSNumber {
            matchId = (m as! NSNumber) == 1
        }

        if image == nil {
            reject(VouchedSessionModule.POST_AUTHENTICATE_FAIL, "Unable to authenticate without an image.", nil)
            return
        } else if jobId == nil {
            reject(VouchedSessionModule.POST_AUTHENTICATE_FAIL, "Unable to authenticate without a job id.", nil)
            return
        }
        

        do {
            let auth = try session?.postAuthenticate(id: jobId!, userPhoto: image!, matchId: matchId)
            let authString = convertObjToString(auth!)
            resolve(authString)
        } catch {
            reject(VouchedSessionModule.POST_AUTHENTICATE_FAIL, error.localizedDescription, error)
        }
        
    }
    
    private func convertObjToString<T>(_ auth: T) -> String? where T: Encodable {
        do {
            return String(data: try JSONEncoder().encode(auth), encoding: .utf8)!
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
 
