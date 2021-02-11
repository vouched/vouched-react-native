import React from 'react';
import { Text, Button, StyleSheet, View } from 'react-native';

const Footer = ({ navigation, message, showHome }) => {
  return (
    <View style={styles.footer}>
      <Text>{message}</Text>
      {showHome && (
        <Button title="Go Home" onPress={() => navigation.navigate('Home')} />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  footer: {
    height: 100,
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center', // Centered horizontally
    backgroundColor: 'white',
    flex: 1
  }
});

export default Footer;
