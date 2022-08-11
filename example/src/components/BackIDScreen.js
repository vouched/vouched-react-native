import React, { useState, useRef, useEffect } from 'react';
import { Button } from 'react-native';
import { StyleSheet, View } from 'react-native';
import Footer from 'components/Footer';
import { VouchedIdCamera, VouchedUtils } from '@vouched.id/vouched-react-native';
import { getSession} from '../common/session'

const BackIDScreen = ({ navigation, route }) => {
  const cameraRef = useRef(null);
  const [message, setMessage] = useState('loading...');
  const [showNextButton, setShowNextButton] = useState(false);
  const [session] = useState(getSession());
  const [params] = useState({});

  const messageByInsight = (insight) => {
      switch (insight) {
          case "NON_GLARE":
              return "image has glare";
          case "QUALITY":
              return "image is blurry";
          case "BRIGHTNESS":
              return "image needs to be brighter";
          case "FACE":
              return "image is missing required visual markers";
          case "GLASSES":
              return "please take off your glasses";
          case "UNKNOWN":
          default:
              return "Unknown Error";
      }
  }

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
                let job = await session.postBackId(cardDetectionResult, params);
                let insights = await VouchedUtils.extractInsights(job);
                if (insights != null && insights.length > 0) {
                  setMessage(messageByInsight(insights[0]));
                  setTimeout(() => {
                    cameraRef.current.restart();
                  }, 5000);
                } else {
                  setMessage("Please continue to next step");
                  setShowNextButton(true);
                }
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
          <Button title="Next Step: Face" onPress={() => navigation.navigate('Face')} />
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

export default BackIDScreen;