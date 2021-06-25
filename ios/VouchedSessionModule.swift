import Vouched

@objc(VouchedSessionModule)
class VouchedSessionModule: NSObject {

    private static let SESSION_NOT_CONFIGURED = "SESSION_NOT_CONFIGURED"
    private static let POST_FRONT_ID_FAIL = "POST_FRONT_ID_FAIL"
    private static let POST_FACE_FAIL = "POST_FACE_FAIL"
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
        
        let image: String? = strFromDict(detectResult, "image")
        let distanceImage: String? = strFromDict(detectResult, "distanceImage")
        
        let cardDetectResult = CardDetectResult(image: image, distanceImage: distanceImage, step: .postable, instruction: .none);

        do {
            var job: Job?;
            if var params = try? DictionaryDecoder().decode(Params.self, from: handleDOB(parameters) as! [String : Any]) {
                job = try session?.postFrontId(detectedCard: cardDetectResult, params: &params)
            } else {
                job = try session?.postFrontId(detectedCard: cardDetectResult)
            }
            
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
        
        let image: String? = strFromDict(detectResult, "image")
        let distanceImage: String? = strFromDict(detectResult, "userDistanceImage")
        
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
        
        let image: String? = strFromDict(authRequest, "image")
        let jobId: String? = strFromDict(authRequest, "jobId")
        
        var matchId: Bool? = nil
        let m = authRequest["matchId"]
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
