import React, { useEffect, useState } from 'react';
import { Button } from 'react-native';
import { StyleSheet, View, Text, PermissionsAndroid } from 'react-native';

const HomeScreen = ({ navigation }) => {

const [hasCameraPermissions, setPermissions] = useState(undefined);

  useEffect(() => {
    // assume all iOS users accept permissions
    if (Platform.OS === 'ios') {
        setPermissions(true);
        return;
    }

    const checkAndroidPermissions = async () => {
      const granted = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.CAMERA);
      setPermissions(granted === PermissionsAndroid.RESULTS.GRANTED);
    };

    checkAndroidPermissions();
  }, []);

  if (hasCameraPermissions === undefined) {
    return (
      <View style={styles.container}>
        <Text> Waiting on Camera Permissions... </Text>
      </View>
    );
  }
  return (
    <View style={styles.container}>
      { !hasCameraPermissions &&
        <Text> Please allow camera permissions </Text>
      }
      <View style={styles.startButton}>
        <Button
          disabled={!hasCameraPermissions}
          title="Start Verification"
          onPress={() => navigation.navigate('ID', { name: 'IDV' })}
        />
      </View>
      <View style={styles.startButton}>
        <Button
          disabled={!hasCameraPermissions}
          title="Start Re-verification"
          onPress={() => navigation.navigate('AuthInput')}
        />
      </View>
      <View style={styles.startButton}>
        <Button
          disabled={!hasCameraPermissions}
          title="Start Selfie Verification"
          onPress={() => navigation.navigate('Face', {verificationType:'selfieVerification'})}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  startButton: {
    padding: '2.5%',
    width: '75%'
  }
});

export default HomeScreen;
