import {VouchedSession } from '@vouched.id/vouched-react-native';

let session;

export const initSession = (apiKey) => {
    session = new VouchedSession(apiKey);
}

export const getSession = () => {
    if (!session) {
        throw "Init Vouched session first."
    }
    return session;
}