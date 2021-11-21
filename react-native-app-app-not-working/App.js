import { StatusBar } from 'expo-status-bar';
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Ionicons from 'react-native-vector-icons/Ionicons';

import mainView from "./mainView"

export default function App() {
  let tabs = createBottomTabNavigator();

  return (
    <NavigationContainer>
      <tabs.Navigator
        screenOptions={({ route }) => ({
          tabBarIcon: ({ focused, color, size }) => {
            let iconName = "ios-calendar";

            return <Ionicons name={iconName} size={size} color={color} />;
          },
        })}
        screenOptions={{
          tabBarActiveTintColor: '#942a21',
          tabBarInactiveTintColor: 'gray',
        }}>

        <tabs.Screen name="mainView" component={mainView} />

      </tabs.Navigator >
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
