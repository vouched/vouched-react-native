import { NativeModules } from 'react-native';

const VouchedUtilsModule = NativeModules.VouchedUtils || NativeModules.VouchedUtilsModule ;

export class VouchedUtils {

    static async extractInsights(job) {
        try {
            const res = await VouchedUtilsModule.extractInsights(job);
            return JSON.parse(res);
        } catch (e) {
            throw e
        }
    }
}