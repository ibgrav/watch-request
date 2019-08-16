//
//  InterfaceController.swift
//  Watch Request WatchKit Extension
//
//  Created by Isaac Graves on 8/9/19.
//  Copyright © 2019 ibgrav. All rights reserved.

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate  {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        processApplicationContext()
    }
    let session = WCSession.default
    
    var sendBtnEnabled = true;
    
    @IBOutlet var sendBtn: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    override func willActivate() {
        super.willActivate()
        
        session.delegate = self
        session.activate()
        
        processApplicationContext()
        
        self.sendBtn.setBackgroundColor(UIColor(red: 0.4, green: 0.6, blue: 0.6, alpha: 1.0))
    }
    override func didDeactivate() {
        super.didDeactivate()
    }

    @IBAction func sendBtnPress() {
        if(sendBtnEnabled) {
            let url: String = globs["url"] ?? ""
            let body: String = globs["body"] ?? ""
            var method: String = globs["method"] ?? ""
            
            switch method {
            case "0": method = "GET"
            case "1": method = "POST"
            case "2": method = "PUT"
            case "3": method = "DELETE"
            default: break
            }
            
            if(globs["url"] != "" && globs["method"] != ""){
                vibrate(vib: .click)
                sendBtnEnabled = false;
                self.sendBtn.setTitle("...");
                
                do {
                    var requestOutput: [String : Any] = [
                        "url": url,
                        "method": method
                    ]
                    var headerVals:String = "";
                    
                    var request = URLRequest(url: URL(string: url)!)
                    request.httpMethod = method
                    
                    if(globs["bodyHeadKey"] != "" && globs["bodyHeadVal"] != "") {
                        request.setValue(globs["bodyHeadVal"], forHTTPHeaderField: globs["bodyHeadKey"] ?? "")
                        headerVals += "\(globs["bodyHeadKey"] ?? ""): \(globs["bodyHeadVal"] ?? "")"
                    }
                    if(globs["headOneKey"] != "" && globs["headOneVal"] != "") {
                        request.setValue(globs["headOneVal"], forHTTPHeaderField: globs["headOneKey"] ?? "")
                        headerVals += "\(globs["headOneKey"] ?? ""): \(globs["headOneVal"] ?? "")"
                    }
                    if(globs["headTwoKey"] != "" && globs["headTwoVal"] != "") {
                        request.setValue(globs["headTwoVal"], forHTTPHeaderField: globs["headTwoKey"] ?? "")
                        headerVals += "\(globs["headTwoKey"] ?? ""): \(globs["headTwoVal"] ?? "")"
                    }
                    if(globs["headThreeKey"] != "" && globs["headThreeVal"] != "") {
                        request.setValue(globs["headThreeVal"], forHTTPHeaderField: globs["headThreeKey"] ?? "")
                        headerVals += "\(globs["headThreeKey"] ?? ""): \(globs["headThreeVal"] ?? "")"
                    }
                    if(globs["headFourKey"] != "" && globs["headFourVal"] != "") {
                        request.setValue(globs["headFourVal"], forHTTPHeaderField: globs["headFourKey"] ?? "")
                        headerVals += "\(globs["headFourKey"] ?? ""): \(globs["headFourVal"] ?? "")"
                    }
                    
                    if(headerVals != ""){
                        requestOutput["headers"] = headerVals;
                    }
                    
                    if(body != "") {
                        request.httpBody = body.data(using: .utf8, allowLossyConversion: false)!
                        requestOutput["body"] = body
                    }
                    
                    globs["httpRequest"] = stringify(json: requestOutput, prettyPrinted: true)
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            self.showResponseView(str:String(error!.localizedDescription), code:999)
                            return
                        }
                        
                        let httpStatus = response as? HTTPURLResponse
                        let statusMsg: Int = Int(httpStatus!.statusCode)
                        
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                let output = stringify(json: json, prettyPrinted: true)
                                self.showResponseView(str:output, code:statusMsg)
                            }
                        } catch let error {
                            print(error.localizedDescription)
                            let str = String(decoding: data, as: UTF8.self)
                            self.showResponseView(str:str, code:statusMsg)
                            
                        }
                    }
                    task.resume()
                }
            } else {
                vibrate(vib: .failure)
                self.sendBtn.setTitle("BAD DATA");
                self.sendBtn.setBackgroundColor(UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0))
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.resetSendBtn()
                }
            }
        }
    }
    
    func resetSendBtn(){
        self.sendBtn.setTitle("Send")
        self.sendBtn.setBackgroundColor(UIColor(red: 0.4, green: 0.6, blue: 0.6, alpha: 1.0))
    }
    
    func showResponseView(str:String, code:Int){
        var codeString:String! = String(code)
        if(code == 999){
            codeString = "NETWORK ERR"
        }
        
        if(globs["debugMode"] == "true"){
            globs["httpCode"] = codeString
            globs["httpResponse"] = str
            self.pushController(withName: "response", context: nil)
        } else {
            self.sendBtn.setTitle(codeString)
            
            if(code < 200) {
                self.sendBtn.setBackgroundColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0))
                vibrate(vib: .retry)
            } else if(code < 300) {
                self.sendBtn.setBackgroundColor(UIColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 1.0))
                vibrate(vib: .success)
            } else if(code < 400) {
                self.sendBtn.setBackgroundColor(UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0))
                vibrate(vib: .failure)
            } else if(code < 500) {
                self.sendBtn.setBackgroundColor(UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0))
                vibrate(vib: .failure)
            } else {
                self.sendBtn.setBackgroundColor(UIColor(red: 1.0, green: 0.2, blue: 1.0, alpha: 1.0))
                vibrate(vib: .failure)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.sendBtnEnabled = true;
            self.resetSendBtn()
        }
    }
    
    func vibrate(vib: WKHapticType){
        WKInterfaceDevice().play(vib)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            WKInterfaceDevice().play(vib)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                WKInterfaceDevice().play(vib)
            }
        }
    }
    
    func processApplicationContext() {
        if let iPhoneContext = session.receivedApplicationContext as? [String : String] {
            globs["method"] = iPhoneContext["method"] ?? "";
            globs["url"] = iPhoneContext["url"] ?? "";
            globs["body"] = iPhoneContext["body"] ?? "";
            globs["bodyHeadKey"] = iPhoneContext["bodyHeadKey"] ?? "";
            globs["bodyHeadVal"] = iPhoneContext["bodyHeadVal"] ?? "";
            globs["headOneVal"] = iPhoneContext["headOneVal"] ?? "";
            globs["headTwoVal"] = iPhoneContext["headTwoVal"] ?? "";
            globs["headThreeVal"] = iPhoneContext["headThreeVal"] ?? "";
            globs["headFourVal"] = iPhoneContext["headFourVal"] ?? "";
            globs["headOneKey"] = iPhoneContext["headOneKey"] ?? "";
            globs["headTwoKey"] = iPhoneContext["headTwoKey"] ?? "";
            globs["headThreeKey"] = iPhoneContext["headThreeKey"] ?? "";
            globs["headFourKey"] = iPhoneContext["headFourKey"] ?? "";
            globs["debugMode"] = iPhoneContext["debugMode"] ?? "";
        }
    }
}

class ResponseInterfaceController: WKInterfaceController  {
    @IBOutlet var outputText: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
       super.willActivate()
        
        let output:String = "\(globs["httpCode"] ?? "")\n\nREQUEST:\n\n\(globs["httpRequest"] ?? "")\n\nRESPONSE:\n\n\(globs["httpResponse"] ?? "")"
        outputText.setText(output);
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}

func stringify(json: Any, prettyPrinted: Bool = false) -> String {
    var options: JSONSerialization.WritingOptions = []
    if prettyPrinted {
        options = JSONSerialization.WritingOptions.prettyPrinted
    }
    
    do {
        let data = try JSONSerialization.data(withJSONObject: json, options: options)
        if let string = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/") {
            return string
        }
    } catch {
        print(error)
    }
    
    return "JSON Serialization Error"
}
