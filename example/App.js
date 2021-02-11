import React from 'react';

import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

import HomeScreen from 'components/HomeScreen';
import IDScreen from 'components/IDScreen';
import FaceScreen from 'components/FaceScreen';
import DoneScreen from 'components/DoneScreen';
import { initSession } from 'common/session'

import { PUBLIC_KEY } from '@env'
initSession(PUBLIC_KEY)

const Stack = createStackNavigator();

const App = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{ title: 'Welcome' }}
        />
        <Stack.Screen
          name="ID"
          component={IDScreen}
          options={{ headerLeft: null }}
        />
        <Stack.Screen
          name="Face"
          component={FaceScreen}
          options={{ headerLeft: null }}
        />
        <Stack.Screen
          name="Done"
          component={DoneScreen}
          options={{ headerLeft: null }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default App;
