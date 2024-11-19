# Lab 11: Platform Device Driver

## Overview
In this lab, we created a device driver for our led patterns componenet so we could write to registers from the command line.

### Questions 
1. **What is the purpose of platform bus?**<br>
The platofrm bus serves to let the OS know what hardware is connected and what resources are available for them.
2. **Why is the device driver’s compatible property important?**<br>
The compatible property of the device driver is important becuase if it doesn't match the compatible property in the device tree, then our driver will not be bound to the device.
3. **What does the probe function do?**<br>
The probe function is called when the device is bound to the device driver. This is where initializations can be done.
4. **How does your driver know what memory addresses are associated with your device?**<br>
The driver knows what memory addresses to use for the device becuase they are set in the `probe` function. The prob function does this by using a structure that maps physical memory addresses into the kernel memory, and setting fields for all three registers used by the LED patterns device.
5. **What are the two ways we can write to our device’s registers? In other words, what subsystems do we use to write to our registers?**<br>
`iowrite` handles all of the hardware-specific details to writing data to a register - this seems to be the common denominator of all the write functions. However, we can use that multiple ways - wether that is from /sys/devices/platform/ff200000_led_patterns or from a bash script or though c scripts where we write to files that are associated with the registers.
6. **What is the purpose of our struct led_patterns_dev state container?**<br>
The purpuse of the state container struct is to keep track of all the unique aspects of the specific device that is connected. A driver can be used for many of the same devices, so it is necessary to keep track of the state of these devices separately. In addition, the state is passed to any functions that need to interact with the devices, and it changes to reflect any changes in state.