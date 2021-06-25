import Vouched

@objc(VouchedUtilsModule)
class VouchedUtilsModule: NSObject {
    private static let EXTRACT_INSIGHTS_FAIL = "EXTRACT_INSIGHTS_FAIL"

    @objc func extractInsights(_ jobDict: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        if let job = try? DictionaryDecoder().decode(Job.self, from: jobDict as! [String : Any]) {
            let insights = VouchedUtils.extractInsights(job);
            resolve(convertInsightsToString(insights));
        } else {
            reject(VouchedUtilsModule.EXTRACT_INSIGHTS_FAIL, "Unable to decode Job", nil);
        }
    
    }
    
    private func convertInsightsToString(_ insights: [Insight]) -> String? {
        let insightStrings: [String] = insights.map { "\"\(convertInsight($0))\"" };
        return "[\(insightStrings.joined(separator: ","))]"
    }
    
    private func convertInsight(_ insight: Insight) -> String {
        switch insight {
        case .nonGlare:
            return "NON_GLARE";
        case .quality:
            return "QUALITY";
        case .brightness:
            return "BRIGHTNESS";
        case .face:
            return "FACE";
        case .glasses:
            return "GLASSES";
        case .unknown:
            return "UNKNOWN";
        @unknown default:
            return "NOT_ADDED";
        }
    }
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
      return true
    }
}
