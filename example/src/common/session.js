import {VouchedSession } from '@vouched.id/vouched-react-native';

let session;

export const initSession = (apiKey, sessionParams) => {
    session = new VouchedSession(apiKey, sessionParams);
}

export const getSession = () => {
    if (!session) {
        throw "Init Vouched session first."
    }
    return session;
}