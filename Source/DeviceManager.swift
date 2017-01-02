//
//  DeviceManager.swift
//  Garmin-ExampleApp-Swift
//  1/1/2017
//
//  The following code is a fully-functional port of Garmin's iOS Example App
//  originally written in Objective-C:
//  https://developer.garmin.com/connect-iq/sdk/
//
//  More details on the Connect IQ iOS SDK can be found at:
//  https://developer.garmin.com/connect-iq/developer-tools/ios-sdk-guide/
//
//  MIT License
//
//  Copyright (c) 2017 Doug Williams - dougw@igudo.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import ConnectIQ
import UIKit

let kDevicesFileName = "devices"

protocol DeviceManagerDelegate {
    func devicesChanged()
}

class DeviceManager: NSObject {
    
    var devices = [IQDevice]()
    var delegate: DeviceManagerDelegate?
    
    static let sharedInstance = DeviceManager()
   
    private override init() {
        // no op
    }
    
    func handleOpenURL(_ url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String else {
            print("handleOpenURL: Source application value was nil, expecting \(IQGCMBundle); disregarind open request, likely not for us.")
            return false
        }
        if (url.scheme! == ReturnURLScheme) && (sourceApplication == IQGCMBundle) {
            
            let devices = ConnectIQ.sharedInstance().parseDeviceSelectionResponse(from: url)
            dump(devices)
            if let devices = devices, devices.count > 0 {
                print("Forgetting \(Int(self.devices.count)) known devices.")
                self.devices.removeAll()
                for (index, device) in devices.enumerated() {
                    guard let device = device as? IQDevice else { continue }
                    print("Received device (\(index+1) of \(devices.count): [\(device.uuid), \(device.modelName), \(device.friendlyName)]")
                    self.devices.append(device)
                    print("status>>> \(ConnectIQ.sharedInstance().getDeviceStatus(device).rawValue)")
                }
                self.saveDevicesToFileSystem()
                self.delegate?.devicesChanged()
                return true
            }
        }
        return false
    }
    
    func saveDevicesToFileSystem() {
        print("Saving known devices.")
        if !NSKeyedArchiver.archiveRootObject(devices, toFile: self.devicesFilePath()) {
            print("Failed to save devices file.")
        }
    }
    
    func restoreDevicesFromFileSystem() {
        guard let restoredDevices = NSKeyedUnarchiver.unarchiveObject(withFile: self.devicesFilePath()) as? [IQDevice] else {
            print("No device restoration file found.")
            return
        }
        
        if restoredDevices.count > 0 {
            print("Restored saved devices:")
            for device in restoredDevices {
                print("\(device)")
            }
            self.devices = restoredDevices
        }
        else {
            print("No saved devices to restore.")
            self.devices.removeAll()
        }
        self.delegate!.devicesChanged()
    }
    
    func devicesFilePath() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let appSupportDirectory = URL(fileURLWithPath: paths[0])
        let dirExists = (try? appSupportDirectory.checkResourceIsReachable()) ?? false
        if !dirExists {
            print("DeviceManager.devicesFilePath appSupportDirectory \(appSupportDirectory) does not exist, creating... ")
            do {
                try FileManager.default.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error {
                print("There was an error creating the directory \(appSupportDirectory) with error: \(error)")
            }
        }
        return appSupportDirectory.appendingPathComponent(kDevicesFileName).absoluteString
    }
}
