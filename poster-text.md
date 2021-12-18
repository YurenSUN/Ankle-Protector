## Draft, 11-27

**Yuren Sun, Senior undergraduate, Computer Sciences, Economics, and Mathematics**

**Smart Ankle Sensor**

**Intent -** Avoid further injury after a mild sprain by tracking movements of the ankle

**Project Description** (Bullet Point List) 

- The product is important as after mild ankle sprains, further injuries might still occur with people's wrong gestures, movement, or compressions. These are hard to detect by people themselves as they will not feel the pain until further injuries are caused. Also, it will take longer and become harder to recover from repeating sprains compared to the first sprain. Therefore, a smart ankle sensor to track the ankle movements and alert users when possible wrong movements are detected is important to avoid further injury during sprain recovery.
- Currently, most products for mild sprain recoveries, such as ankle braces, focus on stabilizing the ankles through compressions. However, they do not fix ankles tightly and still allow ankle movements. Such movements might cause further injury uncautiously if the users do not monitor movements of their ankles continuously. Therefore, we need this smart ankle sensor to track the movements of important parts of ankles and alert users when wrong movements were detected to avoid further injury. At the same time, this product is removable and reusable and users can stick this product to the positions they want after wearing braces or boundage.
- Users still need to use ankle braces to stabilize their ankles. After using braces, they need to stick the sensor part of this product onto the braces with sensors at their desired positions. Then, they need to use the iOS app to connect to the microcontroller through Bluetooth to receive sensor data. Users can set the threshold of sensor data to decide when to send notifications through the app and then start monitoring their ankle movements from the App.
- The product could be extended to be used for all kinds of recoveries that need controlling the movements such as compressing or bending for ankles or elbows.

**Materials and technology incorporated:** 

- The product has two parts - the sensors part and the App. For the sensors part, I use the microcontroller (Arduino 33 BLE), 2 flex sensors, 2 force sensors, with some auxiliary materials including normal and conducting threads, JST female end, and textiles. The sensor part can be powered by a battery (3.3v) with the JST connector. The App is developed with Swift through XCode.
- My process is developing both two parts at the same time. For the sensors part, I first sewed the microcontrollers and sensors to the textiles, and then connected them one after one with conductive threads and move one to the next if the current one is working. After all the sensors are working and the microcontroller can send the data to the phone, I start combining the textile with the tapes and working on some miscellaneous parts for the appearance such as hiding the circuits.
- For the App, I started with React Native but later found that the Bluetooth libraries supported by this framework did not work on my end so I switched to Swift and XCode. When developing the App, I first set up the functions to read data through Bluetooth and the basic UI to display the sensor data. After making sure that the Bluetooth works, I developed other functions such as setting thresholds and sending notifications. Finally, I worked on improving the UI to make it more user-friendly.



## Modified

**Yuren Sun, Senior undergraduate, Computer Sciences, Economics, and Mathematics**

**Smart Ankle Sensor**

**Intent -** Avoid further injury after a mild sprain by tracking movements of the ankle

**Project Description**

- The product is important as after mild ankle sprains, further injuries might still occur with people's harmful gestures, movement, or compressions. These are hard to detect and will take longer and become harder to recover.
- Most available ankle braces stabilize but do not have the ability to monitor harmful movements and alert the wearer. This smart ankle sensor is needed to track the ankle movements and alert users when harmful movements were detected to avoid further injury. At the same time, this product is removable and reusable - users can stick this product to the positions they want after wearing braces
- Users need to simply stick the sensor part onto the braces at their desired positions, and use the iOS app to receive and monitor sensor data through Bluetooth, and send alerts with customized thresholds.
- The product could be extended to be used for all kinds of recoveries that need controlling the movements, such as compressing or bending for ankles or elbows.

**Materials and technology incorporated:** 

- The product has two parts - the sensors part and the App. For the sensors part, I use the microcontroller (Arduino 33 BLE), 2 flex sensors, 2 force sensors, with some auxiliary materials including normal and conducting threads, JST female end, and textiles. The sensor part can be powered by a battery (3.3v) with the JST connector. The App is developed with Swift through XCode.
- My process is developing both two parts at the same time. For the sensors part, I first sewed the microcontrollers and sensors to the textiles, and then connected them one after one with conductive threads and move one to the next if the current one is working. After all the sensors are working and the microcontroller can send the data to the phone, I start combining the textile with the tapes and working on some miscellaneous parts for the appearance such as hiding the circuits.
- For the App, I started with React Native but later found that the Bluetooth libraries supported by this framework did not work on my end so I switched to Swift and XCode. When developing the App, I first set up the functions to read data through Bluetooth and the basic UI to display the sensor data. After making sure that the Bluetooth works, I developed other functions such as setting thresholds and sending notifications. Finally, I worked on improving the UI to make it more user-friendly.
