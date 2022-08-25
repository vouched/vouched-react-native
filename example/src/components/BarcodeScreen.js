import React, { useState, useRef } from 'react';
import { Button } from 'react-native';
import { StyleSheet, View } from 'react-native';
import Footer from 'components/Footer';
import { VouchedBarcodeCamera, VouchedUtils } from '@vouched.id/vouched-react-native';
import { getSession} from '../common/session'

const BarcodeScreen = ({ navigation, route }) => {
  const cameraRef = useRef(null);
  const [message, setMessage] = useState('Place camera over back of ID');
  const [nextScreen, setNextScreen] = useState('Face');
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
          case "UNKNOWN":
          default:
              return "Unknown Error";
      }
  }

  return (
    <View style={styles.container}>
      <View style={styles.camera}>
        <VouchedBarcodeCamera 
          ref={cameraRef} 
          onBarcodeStream={async (barcodeResult) => {
            const { value, image } = barcodeResult;
            if (value !== null || image != null) {
              cameraRef.current.stop();
              setMessage("Processing");
              try {
              let job = await session.postBarcode(barcodeResult);
              let insights = await VouchedUtils.extractInsights(job);

              if (insights != null && insights.length > 0) {
                setMessage(messageByInsight(insights[0]));
                setTimeout(() => {
                  cameraRef.current.restart();
                }, 2000);
              } else {
                setMessage("Please continue to next step");
                setShowNextButton(true);
              }
              } catch (e) {
              console.error(e)
              }        
              } else {
              setMessage("Place over barcode")
              }
              }}
        />
      </View>
      { showNextButton &&
        <View style={styles.nextButton}>
          <Button title="Next Step" onPress={() => navigation.navigate(`${nextScreen}`)} />
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

export default BarcodeScreen;
