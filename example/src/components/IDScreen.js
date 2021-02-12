import React, { useState, useRef, useEffect } from 'react';
import { Button } from 'react-native';
import { StyleSheet, View } from 'react-native';
import Footer from 'components/Footer';
import { VouchedIdCamera } from '@vouched.id/vouched-react-native';
import { getSession} from '../common/session'

const IDScreen = ({ navigation, route }) => {
  const cameraRef = useRef(null);
  const [message, setMessage] = useState('loading...');
  const [showNextButton, setShowNextButton] = useState(false);
  const [session] = useState(getSession())

  return (
    <View style={styles.container}>
      <View style={styles.camera}>
        <VouchedIdCamera 
          ref={cameraRef} 
          enableDistanceCheck={false}
          onIdStream={async (cardDetectionResult) => {
            const { instruction, step } = cardDetectionResult;

            if (step === "POSTABLE") {
              cameraRef.current.stop();
              setMessage("Processing");
              try {
                let job = await session.postFrontId(cardDetectionResult);
                setMessage("Please continue to next step");
                setShowNextButton(true);
              } catch (e) {
                console.error(e)
              }        
            } else {
              setMessage(instruction)
            }
          }}
        />
      </View>
      { showNextButton &&
        <View style={styles.nextButton}>
          <Button title="Next Step" onPress={() => navigation.navigate('Face')} />
        </View>
      }
      <Footer message={message} showHome={true} navigation={navigation} />
    </View>
  );
};

const styles = StyleSheet.create({
  camera: {
    flex: 3,
    flexDirection: 'column'
  },
  nextButton: {
    flex: 1,
    flexDirection: 'column'
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    flexDirection: 'column'
  }
});

export default IDScreen;
