//
//  AppMessageViewController.swift
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

import UIKit
import ConnectIQ

let kMaxLogMessages = 200


class AppMessageViewController: UIViewController, IQDeviceEventDelegate, IQAppMessageDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var tableView: UITableView!

    var appInfo = AppInfo()
    var tableEntries = [TableEntry]()
    var logMessages = [String]()
    
    var device: IQDevice {
        return self.appInfo.app.device
    }
    
    convenience init(_ appInfo: AppInfo) {
        self.init()
        self.appInfo = appInfo
        self.tableEntries = [
            TableEntry(label: "Hello world", message: "Hello World!" as AnyObject),
            TableEntry(label: "String (short)", message: "Hi" as AnyObject),
            TableEntry(label: "String (medium)", message: "Why hello there, good world! This is a medium-length string." as AnyObject),
            TableEntry(label: "String (long)", message: "Lorem ipsum dolor sit amet, pri ex epicuri luptatum, cum tantas partem fastidii an. Ea quot iudicabit vim, vis copiosae repudiandae at. Pri ut agam animal epicuri, nam cu omnis latine voluptatibus. Est dicat viderer ei, at possit sapientem ullamcorper vix, et eum virtute dolorum intellegat. No summo animal forensibus sit, singulis dissentiunt vix at, id congue theophrastus cum. Eam ex semper molestiae, te porro labore mel." as AnyObject),
            TableEntry(label: "Array", message: ["An", "array", "of", "strings", "and", "one", "pi", (3.14159265359)]),
            TableEntry(label: "Dictionary", message: ["key1": "value1", "key2": NSNull(), "key3": (42), "key4": (123.456)]),
            TableEntry(label: "Complex Object", message: ["A string", ["A", "nested", "array"], ["key1": "A nested dictionary", "key2": "three strings...", "key3": "and one array", "key4": ["This array has two strings", "and a nested dictionary!", ["one": (1), "two": (2), "three": (3), "four": (4), "five": (5), (1.61803): "G.R."]]], "And one last null", NSNull()])
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "\(self.appInfo.name) on \(self.device.friendlyName)"
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConnectIQ.sharedInstance().register(forDeviceEvents: self.device, delegate: self)
        ConnectIQ.sharedInstance().register(forAppMessages: self.appInfo.app, delegate: self)
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ConnectIQ.sharedInstance().unregister(forAllDeviceEvents: self)
        ConnectIQ.sharedInstance().unregister(forAllAppMessages: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = self.tableEntries[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "commandcell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "commandcell")
        }
        cell?.textLabel?.text = entry.label
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = self.tableEntries[indexPath.row]
        self.sendMessage(entry.message)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // --------------------------------------------------------------------------------
    // MARK: - METHODS (IQDeviceEventDelegate)
    // --------------------------------------------------------------------------------
    
    func deviceStatusChanged(_ device: IQDevice, status: IQDeviceStatus) {
        // We've only registered to receive status updates for one device, so we don't
        // need to check the device parameter here. We know it's our device.
        if status != .connected {
            // This page's device is no longer connected. Pop back to the device list.
            ConnectIQ.sharedInstance().unregister(forAllAppMessages: self)
            if let navigationController = self.navigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
    // --------------------------------------------------------------------------------
    // MARK: - METHODS (IQAppMessageDelegate)
    // --------------------------------------------------------------------------------
    
    func receivedMessage(_ message: Any, from app: IQApp) {
        // We've only registered to receive messages from our app, so we don't need to
        // check the app parameter here. We know it's our app.
        logMessage("<<<<< Received message: \(message)")
    }
    // --------------------------------------------------------------------------------
    // MARK: - METHODS
    // --------------------------------------------------------------------------------
    
    func sendMessage(_ message: Any) {
        logMessage(">>>>> Sending message: \(message)")
        ConnectIQ.sharedInstance().sendMessage(message, to: self.appInfo.app, progress: {(sentBytes: UInt32, totalBytes: UInt32) -> Void in
            let percent: Double = 100.0 * Double(sentBytes / totalBytes)
            print("Progress: \(percent)% sent \(sentBytes) bytes of \(totalBytes)")
            }, completion: {(result: IQSendMessageResult) -> Void in
                self.logMessage("Send message finished with result: \(NSStringFromSendMessageResult(result))")
        })
    }
    
    func logMessage(_ message: String) {
        print("\(message)")
        self.logMessages.append(message)
        while self.logMessages.count > kMaxLogMessages {
            self.logMessages.remove(at: 0)
        }
        self.logView.text = (self.logMessages as NSArray).componentsJoined(by: "\n")
        self.logView.layoutManager.ensureLayout(for: self.logView.textContainer)
        self.logView.scrollRangeToVisible(NSRange(location: self.logView.text.characters.count - 1, length: 1))
    }
}
