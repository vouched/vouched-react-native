import VouchedCore

@objc(VouchedSessionModule)
class VouchedSessionModule: NSObject {

    private static let SESSION_NOT_CONFIGURED = "SESSION_NOT_CONFIGURED"
    private static let POST_FRONT_ID_FAIL = "POST_FRONT_ID_FAIL"
    private static let POST_BACK_ID_FAIL = "POST_BACK_ID_FAIL"
    private static let POST_BARCODE_FAIL = "POST_BARCODE_FAIL"
    private static let POST_FACE_FAIL = "POST_FACE_FAIL"
    private static let POST_SELFIE_VERIFICATION_FAIL = "POST_SELFIE_VERIFICATION_FAIL"
    private static let POST_CONFIRM_FAIL = "POST_CONFIRM_FAIL"
    private static let POST_AUTHENTICATE_FAIL = "POST_AUTHENTICATE_FAIL"

    private var session: VouchedSession? = nil
    
    @objc func configure(_ apiKey: String, sessionParams vouchedSessionParams: NSDictionary) {
        
//        VouchedLogger.shared.configure(destination: .xcode, level: .debug)
        
        let groupId: String? = strFromDict(vouchedSessionParams, "groupId")
        let callbackURL: String? = strFromDict(vouchedSessionParams, "callbackURL")
        let properties: [JobProperty]? = propertiesFromParams(vouchedSessionParams);

        session = VouchedSession(apiKey: apiKey, sessionParameters: VouchedSessionParameters(groupId: groupId, callbackURL: callbackURL, properties: properties))
        
    }
        
    @objc func postFrontId(_ detectResult: NSDictionary, parameters: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        do {
            let cardDetectResult: CardDetectResult
            if let result = detectResult["result"] as? String {
                cardDetectResult = try JSONDecoder().decode(CardDetectResult.self, from: Data(result.utf8))
            } else {
                cardDetectResult = CardDetectResult(image: nil, distanceImage: nil, step: .postable, instruction: .none, boundingBox: nil)
            }

            var job: Job?
            if let params = try? DictionaryDecoder().decode(Params.self, from: handleDOB(parameters) as! [String : Any]) {
                job = try session?.postCardId(detectedCard: cardDetectResult, details: params)
            } else {
                job = try session?.postCardId(detectedCard: cardDetectResult)
            }
            
            let jobString = convertObjToString(job!)
            resolve(jobString)
        } catch {
            print("\(error)")
            reject(VouchedSessionModule.POST_FRONT_ID_FAIL, error.localizedDescription, error)
        }
        
    }

    @objc func postBackId(_ detectResult: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        do {
            let cardDetectResult: CardDetectResult
            if let result = detectResult["result"] as? String {
                cardDetectResult = try JSONDecoder().decode(CardDetectResult.self, from: Data(result.utf8))
            } else {
                cardDetectResult = CardDetectResult(image: nil, distanceImage: nil, step: .postable, instruction: .none, boundingBox: nil)
            }

            let job = try session?.postCardId(detectedCard: cardDetectResult, isFront: false)
            let jobString = convertObjToString(job!)
            resolve(jobString)
        } catch {
            print("\(error)")
            reject(VouchedSessionModule.POST_BACK_ID_FAIL, error.localizedDescription, error)
        }
        
    }

    @objc func postBarcode(_ detectResult: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        do {
            let barcodeResult: BarcodeResult
            if let result = detectResult["result"] as? String {
                barcodeResult = try JSONDecoder().decode(BarcodeResult.self, from: Data(result.utf8))
                let job = try session?.postBackId(detectedBarcode: barcodeResult)
                let jobString = convertObjToString(job!)
                resolve(jobString)
            }
        } catch {
            print("barcode error: \(error)")
            reject(VouchedSessionModule.POST_BARCODE_FAIL, error.localizedDescription, error)
        }
        
    }
    
    @objc func postFace(_ detectResult: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        do {
            let faceDetectResult: FaceDetectResult

            if let result = detectResult["result"] as? String {
                faceDetectResult = try JSONDecoder().decode(FaceDetectResult.self, from: Data(result.utf8))
            } else {
                faceDetectResult = FaceDetectResult(image: nil, distanceImage: nil, step: .postable, instruction: .none)
            }
            
            let job = try session?.postFace(detectedFace: faceDetectResult)
            let jobString = convertObjToString(job!)
            resolve(jobString)
        } catch {
            reject(VouchedSessionModule.POST_FACE_FAIL, error.localizedDescription, error)
        }
        
    }

        
    @objc func postSelfieVerification(_ detectResult: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }
        
        do {
            let faceDetectResult: FaceDetectResult

            if let result = detectResult["result"] as? String {
                faceDetectResult = try JSONDecoder().decode(FaceDetectResult.self, from: Data(result.utf8))
            } else {
                faceDetectResult = FaceDetectResult(image: nil, distanceImage: nil, step: .postable, instruction: .none)
            }
            
            let job = try session?.postSelfieVerification(detectedFace: faceDetectResult)
            let jobString = convertObjToString(job!)
            resolve(jobString)
        } catch {
            reject(VouchedSessionModule.POST_SELFIE_VERIFICATION_FAIL, error.localizedDescription, error)
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
    
    @objc func postReverify(_ detectResult: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if session == nil {
            reject(VouchedSessionModule.SESSION_NOT_CONFIGURED, "session must be configured", nil);
            return;
        }

        // unpack the dict we passed in
        let jobId = detectResult["jobId"]
        let matchType = detectResult["photoType"]
        let faceDetectDict = detectResult["faceDetectionResult"] as! NSMutableDictionary
        
        do {
            let faceDetectResult: FaceDetectResult
            if let result = faceDetectDict["result"] as? String {
                faceDetectResult = try JSONDecoder().decode(FaceDetectResult.self, from: Data(result.utf8))
            } else {
                faceDetectResult = FaceDetectResult(image: nil, distanceImage: nil, step: .postable, instruction: .none)
            }

        if faceDetectResult.image == nil {
            reject(VouchedSessionModule.POST_AUTHENTICATE_FAIL, "Unable to reverify without an image.", nil)
            return
        } else if jobId == nil {
            reject(VouchedSessionModule.POST_AUTHENTICATE_FAIL, "Unable to reverify without a job id.", nil)
            return
        }
            let auth = try session?.postReverify(jobId: jobId! as! String, userPhoto: faceDetectResult.image!)
            let authString = convertObjToString(auth!)
            resolve(authString)
        } catch {
            reject(VouchedSessionModule.POST_AUTHENTICATE_FAIL, error.localizedDescription, error)
        }
        
    }
    
    private func propertiesFromParams(_ sessionParams: NSDictionary) -> [JobProperty]? {
        let properties = sessionParams["properties"];
        if properties is NSArray {
            let decoder = DictionaryDecoder()
            var jobProperties: [JobProperty] = [];
            for item in properties as! NSArray {
                if item is NSDictionary {
                    if let prop = try? decoder.decode(JobProperty.self, from: item as! [String : Any]) {
                        jobProperties.append(prop)
                    }
                }
            }
            return jobProperties;
        }
        return nil
    }
    
    private func strFromDict(_ dict: NSDictionary, _ selector: String) -> String? {
        let str = dict[selector];
        if str is NSString {
            return (str as! String);
        }
        return nil;
    }

    private func convertObjToString<T>(_ obj: T) -> String? where T: Encodable {
        do {
            return String(data: try JSONEncoder().encode(obj), encoding: .utf8)!
        } catch {
            print(error)
        }
        return nil
    }
    
    private func handleDOB(_ parameters: NSDictionary) -> NSDictionary {
        let mParameters = NSMutableDictionary(dictionary: parameters)
        if mParameters["birthDate"] != nil {
            mParameters["dob"] = mParameters["birthDate"]
        }
        return mParameters
    }
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
      return true
    }

}
 
class DictionaryDecoder {

    public init() {
    }

    private let decoder = JSONDecoder()
    
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        set { decoder.dateDecodingStrategy = newValue }
        get { return decoder.dateDecodingStrategy }
    }
    
    public var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy {
        set { decoder.dataDecodingStrategy = newValue }
        get { return decoder.dataDecodingStrategy }
    }
    
    public var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy {
        set { decoder.nonConformingFloatDecodingStrategy = newValue }
        get { return decoder.nonConformingFloatDecodingStrategy }
    }
    
    public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        set { decoder.keyDecodingStrategy = newValue }
        get { return decoder.keyDecodingStrategy }
    }
    
    public func decode<T>(_ type: T.Type, from dictionary: [String: Any]) throws -> T where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try decoder.decode(type, from: data)
    }
}
