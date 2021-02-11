import {VouchedSession } from 'react-native-vouched';

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