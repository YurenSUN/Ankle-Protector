import React from 'react';
import { StyleSheet, Text, View, Button, TextInput } from 'react-native';
// https://blog.bam.tech/developer-news/make-your-first-iot-react-native-application-with-the-bluetooth-low-energy

// Bluetooth
import { BleManager, Device } from 'react-native-ble-plx';

// One mangaer at a time is allowed
const manager = new BleManager();

export default function mainView() {
  const [isLoading, setIsLoading] = useState(false);

  React.useEffect(() => {
    // detect current state and following state changes
    manager.onStateChange((state) => {
      const subscription = manager.onStateChange((state) => {
        if (state === 'PoweredOn') {
          this.scanAndConnect();
          subscription.remove();
        }
      }, true);
      return () => subscription.remove();
    });
  }, [manager]);

  const scanDevices = () => {
    // display the Activityindicator
    setIsLoading(true);

    // scan devices
    manager.startDeviceScan(null, null, (error, scannedDevice) => {
      if (error) {
        console.warn(error);
      }

      // if a device is detected add the device to the list by dispatching the action into the reducer
      if (scannedDevice) {
        dispatch({ type: 'ADD_DEVICE', payload: scannedDevice });
      }
    });

    // stop scanning devices after 5 seconds
    setTimeout(() => {
      manager.stopDeviceScan();
      setIsLoading(false);
    }, 5000);
  };

  return (
    <View>asdf
      <Button
        title="Clear devices"
        onPress={() => dispatch({ type: 'CLEAR' })}
      />
      {isLoading ? (
        <ActivityIndicator color={'teal'} size={25} />
      ) : (
        <Button title="Scan devices" onPress={scanDevices} />
      )}
    </View>

  )
}