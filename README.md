# bridge_tester
This is the design and code for the bridge tester that we use for testing student bridges. You can learn more about how the bridge tester was created and how we use it by going to this blog post: https://physicsfab.org/2016/04/11/our-custom-designed-bridge-tester/
## The Hardware

- Arduino microcontroller: https://www.sparkfun.com/products/11021
- Adafruit motor shield: https://www.adafruit.com/product/1438
- Sparkfun Load Cell Amplifier: https://www.sparkfun.com/products/13879
- Sparkfun Load Sensor Combinator: https://www.sparkfun.com/products/13878
- Stepper motor

The design of the bridge tester was created using Autodesk Fusion 360 and you can see and even download the project here:
http://a360.co/2oUvVD8

## The Software
The software that runs the system is broken into two parts:

- The Arduino code that reads the four load sensors and also controls the stepper motor.
- The Processing code is the UI that takes commands from the keyboard (s = start, x = stop, p = pause, and then b = backwards) for controlling the stepper motor. When a user presses "x" then the Processing application creates a csv file that is date stamped. This file contains the load sensor data as four columns. The data points are collected at a rate of 10 readings/second.

## Example Data and Graph (in Excel)

## To Do:
We want to improve this in several ways:
- Add a visual indicator when the bridge fails.
- Add multiple data sets to the graph so that all the load sensors are visible.
- Add GUI components for pausing, stopping, reversing, etc.
