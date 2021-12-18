# Smart Ankle Sensor

### Yuren Sun

### A technology-enhanced ankle brace that uses sensors to track harmful movements and alerts the wearer to avoid further injury from mild sprain



### Demo

https://youtu.be/Ei4LR0-7d6Q



### Longer description

My project monitors the ankle movements (bending and rotation) with two flex sensors and compressions on the ankle with two pressure/force sensors. Then, the sensor data will be sent with the microcontroller to a mobile (IOS) App to be viewed by the users through Bluetooth every ~0.1 seconds. Then, users can use the App to track the sensor data, set thresholds, and monitor and send alerts when sensor data exceed the threshold ranges. Users can either set thresholds with retrieved sensor data or manually input the thresholds, including minimum and maximum of flex sensors and maximum of pressure/force sensors. When the App detects that the sensor data exceed thresholds ranges continuously for more 10 times (~1 second), the App will regard the user's movements as incorrect and possibly harmful so that an alert will be sent and notification sounds will be played. When alerting users about harmful movements, information for which sensor(s) is/are detected as out of thresholds ranges will also be given so that the user will understand what movements are detected as incorrect.



### Feelings

I like my project and am pleased that I am able to almost reach what I expected at the beginning. I enjoy learning and working on something that is almost new to me (the sensors part and sewing parts), still being able to work on something that I feel comfortable with (coding and the App), and definitely how the two parts are combined together. This makes me feel that I am able to try and learn new things but still have the whole project under control. I also have a sense of accomplishment and am pretty satisfied with what I turned out as it meets my expectations and goals.



### How well did the project meet theoriginal project description and goals

I think I meet most of my expectations and goals that I finish this project to track the ankle movements with removable sensors, send data to my phone, and use the mobile App to monitor data and alert users for possibly incorrect movement with some customized settings. The only goal that I did not meet is that I do not have two high-threshold pressures sensors at the bottom of the feet to track whether the user relies on both sides of his/her foot evenly because of their high price. I believe I made the correct decision to reduce those parts as I got into much trouble when sewing and will not have enough time to include them in the wearable part even if I purchased them.



### The largest hurdles

I think there are two largest hurdles, sewing (the circuit and the appearances) and getting started with my IOS App. Sewing is somehow really new to me so that I first spent much time deciding the textile to use (huge thanks to prof Marianne on the textile choice :D), how to correctly connect the sensors to microcontroller (such as the resistor choices, connections from sensors to the circuits, not generating short circuits with conductive threads, etc. Huge thanks to prof Kevin on this part!), how to let the sensor work with hook & loop strips, and how to hide the circuits on the front to make it looks less hand-made and better. There were no exact actions or shortcuts for me to overcome those hurdles, and I think I tried and changed many approaches during these parts and did struggle a lot on this but it turned out to be pretty well and I learned a lot from them.

Another hurdle is setting up my IOS App to receive data through Bluetooth. The development process is not hard for me but as this is the first time that I work with Bluetooth, I spent a long time setting up the environment for the App. I first tried React Native as I have much experience with it. However, I tried the top three Bluetooth packages but is not able to resolve any of them (either on my laptop or my phone). As I already spent 2 weeks on it, I decided to change to xCode and Swift. I did not choose this one at first as it is limited to IOS App development but as I have no other familiar choices, I started using it and it works well.



### In future

I would like to extend my project to include the two high-threshold pressure sensors as I hope at the beginning to monitor more parts of feet and ankles. I also hope that my project can be extended to all kinds of monitoring during recoveries for injuries on joints (such as maybe elbow). For the App, I want to try React Native again as I hope that this App can also be used for Android phones. Also, I hope to enable background tracking (i.e., keep tracking and send alerts even when the App only runs in the background) and have more customized functions, such as customized notification or maybe even collect users' data if they approved to do further analysis.



### Materials

Coding/program: microcontroller - Arduino IDE, IOS App - XCode (Swift)

Github repo for all of my works: https://github.com/YurenSUN/smart-ankle-sensor

| **Material**                      | **Quantity** | **Price**                                                    | **Link**                                                     |
| --------------------------------- | ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Arduino Nano 33 BLE               | 1            | $23 + $1.27 tax when I purchased                             | [Amazon](https://www.amazon.com/gp/product/B07WV59YTZ/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1) |
| Hook part of hook and loop tapes  | N/A          | $0, got them from the class                                  | N/A                                                          |
| Flex sensors                      | 2            | $11.28 total - $0 for one from class. Another for $11.28 after tax from Amazon. | [Amazon](https://www.amazon.com/gp/product/B07MHTWR1C/ref=ppx_od_dt_b_asin_title_s00?ie=UTF8&psc=1) |
| force-sensitive resistor - Normal | 2            | $12.77 total - $0 for one from class. $12.77 after tax (purchased on Amazon as there is no delivery fee). | [Amazon](https://www.amazon.com/gp/product/B00B887CLS/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1) |
| Resistors                         | 4            | $0, got them from class                                      | N/A                                                          |
| Normal and Conductive threads     | N/A          | $0, got it from class and have normal threads at home        | N/A                                                          |
| Textiles                          | N/A          | $0, will get them from class                                 | N/A                                                          |
| JST Female End                    | 1            | $7.37 after taxes. Not sure whether this would work. I Will return and find a new one if this does not work | [Amazon](https://www.amazon.com/gp/product/B07NWNPB77/ref=ppx_yo_dt_b_asin_title_o01_s00?ie=UTF8&psc=1) |

 

# Reflections

### What are your personal thoughts and feelings about your finished project?

I like how my project came out and I believe that it matched my expectation at the beginning though I did changed some approaches. I do have the sense of accomplishment as I believe that I learned a lot through this project, either on the sensor part or the App. I also like how I can connect what I am comfortable with (such as coding) to something that is relatively new and finish this project. This gave me the feeling that I step out my comfort zone but being close enough to it to have everything under control (and I like this feeling).

### What are they greatest strides you made in this course?

I think it would be the connections of pure coding, and the wearable part and sensors, to turn out this cool project. I am also really happy about how I overcame struggles in sewing part (circuits and appearances) as I decribed in the final post.

### What else do you wish you would have learned? 

Besides my project, I hope to also learn laser cutting and more about sewing machine. I think we learned about the sewing machine when working on the warm up project but I feel that I am still not confident in my skills for using it.

### What could have made your project better?

I would say if I started with xCode (Swift) from the beginning, then I could save much time on the App development and could work on more functions (such as customized notifications or background functions) or more on the sensors part to make it looks nicer. Simarly, I also spent some extra time on how to combined the sensors and hook & loop strips. I would say I could have save some time from them but I also appreciate the time "wasted" on them as I think I learned new thing when trying out different approaches.



### What worked in this class and should be continued?

I would say almost everything as the course contents are really great, I feel the sense of being supported all the time, and (I believe) it did take us into the world of wearable tech through not too far.

### What aspects of the class do you think could be improved to help you learn more?

### What is something that isn’t currently happening in the course and should be started?

I think it would be good if we can work on some sensors during the warm up project as when I got started with sensors, I only know what is taught on the reading but was struggling on how to choose the resistor, not confident about whether I am connecting them correctly, etc., and sensors are usually pretty useful in our projects.