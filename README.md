# Garmin-ExampleApp-Swift
A Swift 3 version of Garmin's Connect IQ iOS Example App, demonstrating use of the Connect IQ iOS SDK.

This project is a fully-functional Swift 3 port of [Garmin's iOS Example App](https://developer.garmin.com/connect-iq/sdk/), which is offered only in Objective-C.

More details on the Connect IQ iOS SDK can be found at [Garmin's documentation for the Connect IQ iOS SDK](https://developer.garmin.com/connect-iq/developer-tools/ios-sdk-guide/).

## Use:
1. Download and open the project in XCode
2. Update the Provisioning Profile to one of your own (Project Settings -> General -> Signing)
3. Update the Bundle Identifier to one of your own (Project Settings -> Bundle Identifier)
4. Build for and run on your iOS device (the iOS simulator lacks BLE support)

**Note that there is an issue with Garmin's Edge family of devices that renders the Connect IQ iOS SDK BLE channel broken at the time of writing (1/1/2017).**
The Connect IQ team is aware of this bug, but have not committed to a timeline for the fix. See the following posts in the Connect IQ forum for details:
* [https://forums.garmin.com/showthread.php?366206-Edge-1000-CIQ-2-2-1-Communications-transmit](https://forums.garmin.com/showthread.php?366206-Edge-1000-CIQ-2-2-1-Communications-transmit)
* [https://forums.garmin.com/showthread.php?363615-iOS-SDK-returning-a-device-UUID-00000000-0000-0000-0000-000000000000](https://forums.garmin.com/showthread.php?363615-iOS-SDK-returning-a-device-UUID-00000000-0000-0000-0000-000000000000)

The was tested successfully on an iPhone running iOS 10, connecting to a Garmin Forerunner 735XT.

*I, nor this project, are in anyway affiliated with Garmin.*
