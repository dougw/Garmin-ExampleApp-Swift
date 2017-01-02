//
//  AppInfo.swift
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

import Foundation
import ConnectIQ

class AppInfo: NSObject {
    
    var name: String = ""
    var app: IQApp = IQApp()
    var status: IQAppStatus?
    
    convenience init(name: String, iqApp app: IQApp) {
        self.init()
        self.name = name
        self.app = app
        self.status = nil
        getStatus()
    }
    
    convenience init(name: String, iqApp app: IQApp, status: IQAppStatus) {
        self.init()
        self.name = name
        self.app = app
        self.status = status
    }
    
    func getStatus() {
        ConnectIQ.sharedInstance().getAppStatus(self.app, completion: { (appStatus: IQAppStatus?) in
            self.status = IQAppStatus()
        })
    }


    func updateStatus(withCompletion completion: @escaping (_ appInfo: AppInfo) -> Void) {
        ConnectIQ.sharedInstance().getAppStatus(self.app, completion: { (appStatus: IQAppStatus?) in
            self.status = appStatus
            completion(self)
        })
    }
}
