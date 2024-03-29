import React, { useState, useRef, useEffect } from 'react';
import { Alert, Button } from 'react-native';
import { StyleSheet, View, Text } from 'react-native';
import Footer from 'components/Footer';
import { VouchedIdCamera, VouchedUtils } from '@vouched.id/vouched-react-native';
import { getSession} from '../common/session'
import { getLocation } from '../common/GeolocationUtils'
import * as Consts from '../common/Consts' 

const IDScreen = ({ navigation, route }) => {
  const cameraRef = useRef(null);
  const [message, setMessage] = useState('Place camera over front of ID');
  const [nextScreen, setNextScreen] = useState('Face')
  const [showNextButton, setShowNextButton] = useState(false);
  const [session] = useState(getSession());
  const [params, setParams] = useState({});

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

  const geoLocationMessage = (geoLocationData) => {
    if(!Consts.GEOLOCATION_FEATURE_ENABLED) return "";
    if(geoLocationData == null){
      return "Getting geolocation data";
    } else if(geoLocationData.latitude && geoLocationData.longitude){
      return `Lat: ${geoLocationData.latitude}  Lng: ${geoLocationData.longitude}`;
    }
    return "Unable to determine user location"
  }

  const fetchLocation = ()=> {
    getLocation().then(
      result => {
        setParams({
          ...params,
          geoLocation:{
            latitude: result.coords.latitude,
            longitude: result.coords.longitude
          }
        })
      },
      error => {
        setParams({
          ...params,
          geoLocation:{
            error: "Unable to determine user location"
          }
        })
        if(error){
          Alert.alert(`Code ${error.code}`, error.message);
        }
      }
    );
  }

  useEffect(()=> {
    if(Consts.GEOLOCATION_FEATURE_ENABLED){
      fetchLocation();
    }
  }, []);

  return (
    <View style={styles.container}>
      <View style={styles.camera}>
	    {Consts.GEOLOCATION_FEATURE_ENABLED && <Text>{geoLocationMessage(params.geoLocation)}</Text>}
        <VouchedIdCamera 
          ref={cameraRef} 
          enableDistanceCheck={false}
          onIdStream={async (cardDetectionResult) => {
            const { instruction, step } = cardDetectionResult;

            if (step === "POSTABLE") {
              cameraRef.current.stop();
              setMessage("Processing");
              try {
                let job = await session.postFrontId(cardDetectionResult, params);
                let insights = await VouchedUtils.extractInsights(job);

                if (insights != null && insights.length > 0) {
                  setMessage(messageByInsight(insights[0]));
                  setTimeout(() => {
                    cameraRef.current.restart();
                  }, 5000);
                } else {
                  setMessage("Please continue to next step");
                  if (job.result.captureBackId == true) {
                    setMessage("Flip ID over to scan back of ID");  
                    setNextScreen('BackID');
                  } 
                  // note: if the backside and the barcode are 
                  // requested, use the barcode scan, its much faster
                  if (job.result.hasPDF417Back == true) {
                    setMessage("Flip ID over to scan barcode");  
                    setNextScreen('Barcode');
                  } 
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

export default IDScreen;
