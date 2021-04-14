import React, { useState } from 'react';
import { StyleSheet, View, Text, TextInput } from 'react-native';
import { AUTH_BASE_COLOR } from 'common/colors';

const AuthInputScreen = ({ navigation, route }) => {
  const [jobId, setJobId] = useState('');

  const onSubmitEditing = ({ nativeEvent }) => {
    const { text } = nativeEvent;
    navigation.navigate('Auth', { jobId: text, matchId: true })
  }

  return (
    <View style={styles.container}>
      <View style={styles.inputContainer}>
        <Text style={{ color: 'white' }}> Enter the Vouched job id to authenticate </Text>
        <TextInput
          style={styles.input}
          autoCapitalize='none'
          autoCompleteType='off'
          autoCorrect={false}
          autoFocus={true}
          enablesReturnKeyAutomatically={true}
          onChangeText={setJobId}
          value={jobId}
          onSubmitEditing={onSubmitEditing}
          returnKeyType='next'
        />
      </View>
      <View style={{ flex: 1 }} ></View>
    </View>
  );
};

const styles = StyleSheet.create({
  input: {
    padding: '2.5%',
    color: 'white',
    fontWeight: '600',
    letterSpacing: 1.2,
  },
  inputContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: AUTH_BASE_COLOR
  }
});

export default AuthInputScreen;
