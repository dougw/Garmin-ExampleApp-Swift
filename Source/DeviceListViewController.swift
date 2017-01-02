//
//  DeviceListViewController.swift
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

class DeviceListViewController: UIViewController, DeviceManagerDelegate, IQDeviceEventDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!

    let deviceManager = DeviceManager.sharedInstance
    
    class func deviceListViewController() -> DeviceListViewController {
        let storyboard = UIStoryboard.init(name: "DeviceList", bundle: nil)
        return storyboard.instantiateInitialViewController() as! DeviceListViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Connect IQ Devices"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let nib = UINib(nibName: "DeviceTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "iqdevicecell")
        self.deviceManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for device: IQDevice in self.deviceManager.devices {
            print("Registering for device events from '\(device.friendlyName)'")
            ConnectIQ.sharedInstance().register(forDeviceEvents: device, delegate: self)
        }
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ConnectIQ.sharedInstance().unregister(forAllDeviceEvents: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func findDevicesButtonPressed(_ sender: AnyObject) {
        ConnectIQ.sharedInstance().showDeviceSelection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceManager.devices.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = self.deviceManager.devices[indexPath.row]
        let status = ConnectIQ.sharedInstance().getDeviceStatus(device)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "iqdevicecell", for: indexPath) as! DeviceTableViewCell
        cell.nameLabel.text! = device.friendlyName
        cell.modelLabel.text! = device.modelName
        switch status {
        case .invalidDevice:
            cell.statusLabel.text! = "Invalid Device"
            cell.enabled = false
        case .bluetoothNotReady:
            cell.statusLabel.text! = "Bluetooth Off"
            cell.enabled = false
        case .notFound:
            cell.statusLabel.text! = "Not Found"
            cell.enabled = false
        case .notConnected:
            cell.statusLabel.text! = "Not Connected"
            cell.enabled = false
        case .connected:
            cell.statusLabel.text! = "Connected"
            cell.enabled = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = self.deviceManager.devices[indexPath.row]
        let status = ConnectIQ.sharedInstance().getDeviceStatus(device)
        if status == .connected {
            let vc = DeviceAppListViewController(device)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func devicesChanged() {
        for device: IQDevice in self.deviceManager.devices {
            ConnectIQ.sharedInstance().register(forDeviceEvents: device, delegate: self)
        }
        self.tableView.reloadData()
    }

    func deviceStatusChanged(_ device: IQDevice, status: IQDeviceStatus) {
        self.tableView.reloadData()
    }
}
