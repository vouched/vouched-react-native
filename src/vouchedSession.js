import { NativeModules } from 'react-native';

const VouchedSessionModule = NativeModules.VouchedSession || NativeModules.VouchedSessionModule ;

export class VouchedSession {

    constructor(apiKey) {
        VouchedSessionModule.configure(apiKey);
    }

    async postFrontId(cardDetectionResult, paramaters) {
        try {
            return await VouchedSessionModule.postFrontId(cardDetectionResult);
        } catch (e) {
            throw e
        }
    }
    
    async postFace(faceDetectionResult) {
        try {
            return await VouchedSessionModule.postFace(faceDetectionResult);
        } catch (e) {
            throw e
        }
    }
    
    async confirm() {
        try {
            return await VouchedSessionModule.confirm();
        } catch (e) {
            throw e
        }
    }
    
}