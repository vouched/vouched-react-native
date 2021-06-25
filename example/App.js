import React from 'react';
import { Button } from 'react-native';

import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

import HomeScreen from 'components/HomeScreen';
import IDScreen from 'components/IDScreen';
import FaceScreen from 'components/FaceScreen';
import DoneScreen from 'components/DoneScreen';
import AuthScreen from 'components/AuthScreen';
import AuthInputScreen from 'components/AuthInputScreen';
import { initSession } from 'common/session';

import { AUTH_BASE_COLOR } from 'common/colors';

import { PUBLIC_KEY } from '@env'

const sessionParams = { 
  properties: []
};
initSession(PUBLIC_KEY, sessionParams)

const Stack = createStackNavigator();

const App = () => {
  const navigationRef = React.useRef(null);

  return (
    <NavigationContainer ref={navigationRef}>
      <Stack.Navigator>
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{ title: 'Welcome' }}
        />
        <Stack.Screen
          name="AuthInput"
          component={AuthInputScreen}
          options={{ 
            title: null, 
            headerLeft: null, 
            headerStyle: {
              backgroundColor: AUTH_BASE_COLOR,
            } 
          }}
        />
        <Stack.Screen
          name="Auth"
          component={AuthScreen}
          options={{ 
            title: null, 
            headerLeft: null, 
            headerStyle: {
              backgroundColor: AUTH_BASE_COLOR,
              height: 60
            },
            headerRight: () => (
              <Button
                onPress={() => navigationRef.current.goBack()}
                title="X"
                color="#fff"
              />
            )
          }}
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
