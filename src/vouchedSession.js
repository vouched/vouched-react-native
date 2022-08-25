import { NativeModules } from 'react-native';

const VouchedSessionModule = NativeModules.VouchedSession || NativeModules.VouchedSessionModule ;

export class VouchedSession {

    constructor(apiKey, sessionParams={}) {
        VouchedSessionModule.configure(apiKey, sessionParams);
    }

    async postFrontId(cardDetectionResult, params={}) {
        try {
            const res = await VouchedSessionModule.postFrontId(cardDetectionResult, params);
            return JSON.parse(res);
        } catch (e) {
            throw e
        }
    }

    async postBackId(cardDetectionResult) {
        try {
            const res = await VouchedSessionModule.postBackId(cardDetectionResult);
            return JSON.parse(res);
        } catch (e) {
            throw e
        }
    }

    async postBarcode(barcodeResult) {
        try {
            const res = await VouchedSessionModule.postBarcode(barcodeResult);
            return JSON.parse(res);
        } catch (e) {
            throw e
        }
    }
    
    async postFace(faceDetectionResult) {
        try {
            const res = await VouchedSessionModule.postFace(faceDetectionResult);
            return JSON.parse(res);
        } catch (e) {
            throw e
        }
    }
    
    async confirm() {
        try {
            const res = await VouchedSessionModule.confirm();
            return JSON.parse(res);
        } catch (e) {
            throw e
        }
    }

    async postReverify(faceDetectionResult, jobId, photoType) {
        try {
            const res = await VouchedSessionModule.postReverify({
                faceDetectionResult,
                jobId,
                photoType
            });
            return JSON.parse(res);
        } catch (e) {
            throw e
        }
    }
    
}