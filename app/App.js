import { StatusBar } from 'expo-status-bar';
import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Ionicons from 'react-native-vector-icons/Ionicons';

import { BleManager } from 'react-native-ble-plx';


export default function App() {
  let tabs = createBottomTabNavigator();

  return (
    <NavigationContainer>
    < tabs.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName = "ios-calendar";

          // if (route.name === 'Today') {
          //   iconName = "ios-calendar";
          // } else if (route.name === 'Exercises') {
          //   iconName = "ios-walk";
          // } else if (route.name === 'Profile') {
          //   iconName = "ios-person";
          // } else if (route.name === 'Meals') {
          //   iconName = "ios-pizza"
          // }

          return <Ionicons name={iconName} size={size} color={color} />;
        },
      })}
      tabBarOptions={{
        activeTintColor: '#942a21',
        inactiveTintColor: 'gray',
      }}>
      <>
        {/* main view */}
        <tabs.Screen name="main" component={mainView} options={{headerShown: true}} />

        {/* exercises */}
        {/* <tabs.Screen name="Exercises">
          {(props) => <ExercisesView {...props} username={this.props.username} accessToken={this.props.accessToken} />}
        </tabs.Screen> */}

        {/* exercises */}
        {/* <tabs.Screen name="Meals">
          {(props) => <MealsView {...props} username={this.props.username} accessToken={this.props.accessToken} />}
        </tabs.Screen> */}

        {/* profile */}
        {/* <tabs.Screen name="Profile">
          {(props) => <ProfileView {...props} username={this.props.username} accessToken={this.props.accessToken} />}
        </tabs.Screen> */}
      </>
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
