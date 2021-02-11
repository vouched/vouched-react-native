import React, { useEffect, useState } from 'react';
import Footer from 'components/Footer';
import { StyleSheet, View, Text } from 'react-native';
import { getSession} from '../common/session'

const DoneScreen = ({ navigation }) => {
  const [job, setJob] = useState()
  const [jobSuccess, setJobSuccess] = useState()
  const [session] = useState(getSession())

  useEffect(() => {

    const confirmJob = async () => {
      const job = await session.confirm();
      setJob(job);
      setJobSuccess(job.result && job.result.success);
    }

    confirmJob();
  }, []);

  if (!job) {
    return (
      <View style={styles.container}>
        <Text> waiting... </Text>
        <Footer message={null} showHome={true} navigation={navigation} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
        <Text> Thank you for verifying. Please continue </Text>
      <Footer message={null} showHome={true} navigation={navigation} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    flexDirection: 'column'
  }
});

export default DoneScreen;
