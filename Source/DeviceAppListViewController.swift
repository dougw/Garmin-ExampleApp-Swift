//
//  DeviceAppListViewController.swift
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


class DeviceAppListViewController: UIViewController, IQDeviceEventDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var installButton: UIButton!
    
    var device: IQDevice?
    var appInfos = NSMutableDictionary()
    var currentAppId: UUID?
    
    convenience init(_ device: IQDevice) {
        self.init()
        self.device = device
        let loopbackApp = IQApp(uuid: UUID(uuidString: "0180e520-5f7e-11e4-9803-0800200c9a66"), store: UUID(), device: device)
        let stringApp = IQApp(uuid: UUID(uuidString: "a3421fee-d289-106a-538c-b9547ab12095"), store: UUID(), device: device)
        let gameApp = IQApp(uuid: UUID(uuidString: "3bc0423d-5f82-46bb-8396-e714f608232f"), store: UUID(uuidString: "8ecc61f6-541e-45e7-b227-278a39abefd8"), device: device)


        self.appInfos[loopbackApp!.uuid] = AppInfo(name: "Loopback Test App", iqApp: loopbackApp!)
        self.appInfos[stringApp!.uuid] = AppInfo(name: "String Test App", iqApp: stringApp!)
        self.appInfos[gameApp!.uuid] = AppInfo(name: "2048 App", iqApp: gameApp!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let device = device else {
            assertionFailure("device must be not nil. Use init(device: IQDevice) to init.")
            return
        }
        self.navigationItem.title = device.friendlyName
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let nib = UINib(nibName: "AppTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "iqappcell")
        self.currentAppId = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConnectIQ.sharedInstance().register(forDeviceEvents: self.device, delegate: self)
        self.tableView.reloadData()
        for appInfo: AppInfo in self.appInfos.allValues as! [AppInfo] {
            appInfo.updateStatus(withCompletion: {(appInfo: AppInfo) -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ConnectIQ.sharedInstance().unregister(forAllDeviceEvents: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCurrentAppID(_ currentAppID: UUID) {
        self.currentAppId = currentAppID
        let appInfo = self.appInfos[currentAppID] as! AppInfo
        
        guard let status = appInfo.status, status.isInstalled else {
            self.installButton.isEnabled = true
            self.installButton.backgroundColor = UIColor(red: 0.655, green: 0.792, blue: 1.0, alpha: 1.0)
            return
        }
        
        self.installButton.isEnabled = false
        self.installButton.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func installButtonPressed(_ sender: Any) {
        guard let currentAppInfo = self.appInfos[self.currentAppId!] as? AppInfo else {
            print("Failed to install app -- currentAppInfo is unexpectedly nil")
            return
        }
        print("Installing '\(currentAppInfo.name)'")
        ConnectIQ.sharedInstance().showStore(for: currentAppInfo.app)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appInfos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appKey = self.appInfos.allKeys[indexPath.row]
        let appInfo = self.appInfos[appKey] as! AppInfo
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "iqappcell", for: indexPath) as! AppTableViewCell
        cell.nameLabel.text = appInfo.name
        let installed: Bool = appInfo.status?.isInstalled ?? false
        cell.installedLabel.text = installed ? "Installed (v\(appInfo.status!.version))" : "Not installed"
        cell.enabled = installed
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appKey = self.appInfos.allKeys[indexPath.row] as! UUID
        self.currentAppId = appKey
        let appInfo = self.appInfos[appKey] as! AppInfo
        if appInfo.status?.isInstalled ?? false {
            let vc = AppMessageViewController(appInfo)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let appKey = self.appInfos.allKeys[indexPath.row] as! UUID
        let appInfo = self.appInfos[appKey] as! AppInfo
        ConnectIQ.sharedInstance().showStore(for: appInfo.app)
    }
    
    // --------------------------------------------------------------------------------
    // MARK: - METHODS (IQDeviceEventDelegate)
    // --------------------------------------------------------------------------------
    
    func deviceStatusChanged(_ device: IQDevice, status: IQDeviceStatus) {
        // We've only registered to receive status updates for one device, so we don't
        // need to check the device parameter here. We know it's our device.
        if status != .connected {
            // This page's device is no longer connected. Pop back to the device list.
            if let navigationController = self.navigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
    
}
