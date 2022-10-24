import {
    Alert,
    PermissionsAndroid,
    Platform,
    Linking,
    ToastAndroid
  } from 'react-native';

  import Geolocation, { GeoPosition } from 'react-native-geolocation-service';

  const openIOSSettings = () => {
    Linking.openSettings().catch(() => {
      Alert.alert('Something went wrong when trying to open settings');
    });
  };

  const hasPermissionIOS = async () => {
    
    const status = await Geolocation.requestAuthorization('whenInUse');

    if (status === 'granted') {
      return true;
    }else if(status === 'denied'){
        Alert.alert('Location permission denied');
    }else if(status === 'disabled'){
        Alert.alert(
            "Turn on location services to allow this example app to access your location",
            '',
            [
              { text: 'Go to Settings', onPress: openIOSSettings },
              { text: "Cancel", onPress: () => {} },
            ],
          );
    }
    return false;
  };

  const hasPermissionAndroid = async () => {
    if (Platform.Version < 23) {
        return true;
    }

    const permissionsAlreadyGranted = await PermissionsAndroid.check(
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
    );
    
    if(permissionsAlreadyGranted){ 
        return true; 
    }
    
    const status = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
      );
  
    if (status === PermissionsAndroid.RESULTS.GRANTED) {
        return true;
    } else if(status === PermissionsAndroid.RESULTS.DENIED) {
        ToastAndroid.show(
            "Location permission denied by the user",
            ToastAndroid.LONG,
          );
    } else if(status === PermissionsAndroid.RESULTS.NEVER_ASK_AGAIN){
        ToastAndroid.show(
            "Location permission revoked by the user",
            ToastAndroid.LONG,
          );
    }
  }

  const hasLocationPermission = async () => {
    if (Platform.OS === 'ios') {
      return await hasPermissionIOS();
    } else if(Platform.OS === 'android'){
        return await hasPermissionAndroid();
    }
    console.error(`error determining location permissions: Unknown OS "${Platform.OS}"`);
    return false;
  };

  export const getLocation = () => {
    return new Promise(async (resolve, reject) => {
        if (!await hasLocationPermission()) {
            return reject(null);
        }
        Geolocation.getCurrentPosition(
            position => {
                resolve(position);
            },
            error => {
                reject(error);
            },
            {
              accuracy: {
                android: 'high',
                ios: 'best',
              },
              enableHighAccuracy: true,
              timeout: 15000,
              maximumAge: 10000,
              distanceFilter: 0,
              forceRequestLocation: true,
              forceLocationManager: false,
              showLocationDialog: true,
            },
          );

    });
  };