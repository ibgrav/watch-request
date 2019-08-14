//
//  ViewController.swift
//  Watch Request
//
//  Created by Isaac Graves on 8/9/19.
//  Copyright © 2019 ibgrav. All rights reserved.
//

import UIKit
import WatchConnectivity

class LandingViewController: UIViewController, WCSessionDelegate {
    
    var session: WCSession?
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { }
    
    @IBOutlet var sendWatchBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        setBtnStyle(btn:sendWatchBtn, radius:20.0, shadow:5.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    @IBAction func sendWatchPress(_ sender: UIButton) {
        sendWatchBtn.isEnabled = false
        
        let method = UserDefaults.standard.string(forKey: "method") ?? ""
        let url = UserDefaults.standard.string(forKey: "url") ?? ""
        let body = UserDefaults.standard.string(forKey: "body") ?? ""
        let bodyType = UserDefaults.standard.string(forKey: "body") ?? ""
        let headOneVal = UserDefaults.standard.string(forKey: "headOneVal") ?? ""
        let headTwoVal = UserDefaults.standard.string(forKey: "headTwoVal") ?? ""
        let headThreeVal = UserDefaults.standard.string(forKey: "headThreeVal") ?? ""
        let headFourVal = UserDefaults.standard.string(forKey: "headFourVal") ?? ""
        let headOneKey = UserDefaults.standard.string(forKey: "headOneKey") ?? ""
        let headTwoKey = UserDefaults.standard.string(forKey: "headTwoKey") ?? ""
        let headThreeKey = UserDefaults.standard.string(forKey: "headThreeKey") ?? ""
        let headFourKey = UserDefaults.standard.string(forKey: "headFourKey") ?? ""
        let debugMode = UserDefaults.standard.bool(forKey: "watchDebugMode")
        
        if(verifyUrl(urlString: url)) {
            
            if let validSession = session {
                //all items to pass to watch
                let iPhoneAppContext:[String:Any] = [
                    "method": method,
                    "url": url,
                    "body": body,
                    "bodyType": bodyType,
                    "headOneVal": headOneVal,
                    "headTwoVal": headTwoVal,
                    "headThreeVal": headThreeVal,
                    "headFourVal": headFourVal,
                    "headOneKey": headOneKey,
                    "headTwoKey": headTwoKey,
                    "headThreeKey": headThreeKey,
                    "headFourKey": headFourKey,
                    "debugMode": debugMode
                    ]
                
                do {
                    //send to watch
                    try validSession.updateApplicationContext(iPhoneAppContext)
                    self.sendWatchBtn.setTitle("Ready!", for: .normal)
                    self.sendWatchBtn.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1)
                } catch {
                    self.sendWatchBtn.setTitle("Watch Error", for: .normal)
                    self.sendWatchBtn.backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
                }
            }
        } else {
            self.sendWatchBtn.setTitle("Invalid URL!", for: .normal)
            self.sendWatchBtn.backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1)
        }
        
        resetSendWatchBtn()
    }
    
    func resetSendWatchBtn(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.sendWatchBtn.isEnabled = true;
            self.sendWatchBtn.setTitle("Ready Watch", for: .normal)
            self.sendWatchBtn.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1)
        }
    }
}

class InfoViewController: UIViewController {
    
    @IBOutlet var watchDebugSwitch: UISwitch!
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(watchDebugSwitch.isOn, forKey: "watchDebugMode")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let debugMode:Bool = UserDefaults.standard.bool(forKey: "watchDebugMode")
        watchDebugSwitch.isOn = debugMode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class RequestViewController: UIViewController {
    
    @IBOutlet var httpMethod: UISegmentedControl!
    @IBOutlet var httpUrl: UITextField!
    @IBOutlet var httpBodyType: UISegmentedControl!
    @IBOutlet var httpBody: UITextView!
    @IBOutlet var httpHeaderKey: UITextField!
    @IBOutlet var httpHeaderVal: UITextField!
    @IBOutlet var httpSendBtn: UIButton!
    @IBOutlet var httpHeadersOutput: UITextView!
    @IBOutlet var httpHeadCounter: UIStepper!
    
    override func viewWillDisappear(_ animated: Bool) {
        var bodyTypeText = "TEXT";
        switch httpBodyType.selectedSegmentIndex {
        case 0: bodyTypeText = "TEXT"
        case 1: bodyTypeText = "JSON"
        default: break
        }
        
        var methodText = "GET";
        switch httpMethod.selectedSegmentIndex {
        case 0: methodText = "GET"
        case 1: methodText = "POST"
        case 2: methodText = "PUT"
        case 3: methodText = "DELETE"
        default: break
        }
        
        UserDefaults.standard.set(httpUrl.text, forKey: "url")
        UserDefaults.standard.set(httpBody.text, forKey: "body")
        UserDefaults.standard.set(bodyTypeText, forKey: "bodyType")
        UserDefaults.standard.set(methodText, forKey: "method")
        UserDefaults.standard.set(headOne["val"], forKey: "headOneVal")
        UserDefaults.standard.set(headTwo["val"], forKey: "headTwoVal")
        UserDefaults.standard.set(headThree["val"], forKey: "headThreeVal")
        UserDefaults.standard.set(headFour["val"], forKey: "headFourVal")
        UserDefaults.standard.set(headOne["key"], forKey: "headOneKey")
        UserDefaults.standard.set(headTwo["key"], forKey: "headTwoKey")
        UserDefaults.standard.set(headThree["key"], forKey: "headThreeKey")
        UserDefaults.standard.set(headFour["key"], forKey: "headFourKey")
        
        UserDefaults.standard.set(httpHeadCounter.value, forKey: "headCount")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var headerText = ""
        let url = UserDefaults.standard.string(forKey: "url") ?? ""
        let body = UserDefaults.standard.string(forKey: "body") ?? ""
        let bodyType = UserDefaults.standard.string(forKey: "bodyType") ?? ""
        let headKey = UserDefaults.standard.string(forKey: "headKey") ?? ""
        let headVal = UserDefaults.standard.string(forKey: "headVal") ?? ""
        let method = UserDefaults.standard.string(forKey: "method") ?? ""
        let headCount = UserDefaults.standard.double(forKey: "headCount")
        
        httpHeadCounter.value = headCount
        
        headOne["key"] = UserDefaults.standard.string(forKey: "headOneKey")
        headTwo["key"] = UserDefaults.standard.string(forKey: "headTwoKey")
        headThree["key"] = UserDefaults.standard.string(forKey: "headThreeKey")
        headFour["key"] = UserDefaults.standard.string(forKey: "headFourKey")
        
        headOne["val"] = UserDefaults.standard.string(forKey: "headOneVal")
        headTwo["val"] = UserDefaults.standard.string(forKey: "headTwoVal")
        headThree["val"] = UserDefaults.standard.string(forKey: "headThreeVal")
        headFour["val"] = UserDefaults.standard.string(forKey: "headFourVal")
        
        headOne != [:] ? headerText += "\(headOne["key"] ?? "") : \(headOne["val"] ?? "")\n" : nil
        headTwo != [:] ? headerText += "\(headTwo["key"] ?? "") : \(headTwo["val"] ?? "")\n" : nil
        headThree != [:] ? headerText += "\(headThree["key"] ?? "") : \(headThree["val"] ?? "")\n" : nil
        headFour != [:] ? headerText += "\(headFour["key"] ?? "") : \(headFour["val"] ?? "")" : nil
        
        headOne != [:] ? httpHeadCounter.value = 1.0 : nil
        headTwo != [:] ? httpHeadCounter.value = 2.0 : nil
        headThree != [:] ? httpHeadCounter.value = 3.0 : nil
        headFour != [:] ? httpHeadCounter.value = 4.0 : nil
        
        httpHeadersOutput.text = headerText
        
        httpUrl.text = url
        httpBody.text = body
        httpHeaderKey.text = headKey
        httpHeaderVal.text = headVal
    
        switch bodyType {
        case "TEXT": httpBodyType.selectedSegmentIndex = 0
        case "JSON": httpBodyType.selectedSegmentIndex = 1
        default: break
        }
        
        switch method {
        case "GET": httpMethod.selectedSegmentIndex = 0
        case "POST": httpMethod.selectedSegmentIndex = 1
        case "PUT": httpMethod.selectedSegmentIndex = 2
        case "DELETE": httpMethod.selectedSegmentIndex = 3
        default: break
        }
        
        httpBody.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        httpBody.layer.borderWidth = 0.5
        httpBody.layer.cornerRadius = 6.0
        
        setSegmentStyle(seg:httpMethod)
        setSegmentStyle(seg:httpBodyType)
        setBtnStyle(btn: httpSendBtn, radius:5.0, shadow:0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //HTTP SETTINGS ACTIONS
    
    @IBAction func headerCount(_ sender: UIStepper) {
        let count = Double(sender.value);
        var headerText = ""
        var headCheck:Bool = true;
        let prevCount = UserDefaults.standard.double(forKey: "headCount")
        
        if(httpHeaderKey.text == "" && httpHeaderVal.text == ""){
            headCheck = false;
        }
        
        if(count == 4){
            if(headCheck){
                headFour["key"] = httpHeaderKey.text ?? ""
                headFour["val"] = httpHeaderVal.text ?? ""
            } else {
                sender.value -= 1.0;
            }
        } else if(count == 3){
            if(count > prevCount){
                if(headCheck) {
                    headThree["key"] = httpHeaderKey.text ?? ""
                    headThree["val"] = httpHeaderVal.text ?? ""
                } else {
                    sender.value -= 1.0;
                }
            } else {
                headFour = [:]
            }
        } else if(count == 2){
            if(count > prevCount){
                if(headCheck) {
                    headTwo["key"] = httpHeaderKey.text ?? ""
                    headTwo["val"] = httpHeaderVal.text ?? ""
                } else {
                    sender.value -= 1.0;
                }
            } else {
                headThree = [:]
            }
        } else if(count == 1){
            if(count > prevCount){
                if(headCheck) {
                    headOne["key"] = httpHeaderKey.text ?? ""
                    headOne["val"] = httpHeaderVal.text ?? ""
                } else {
                    sender.value -= 1.0;
                }
            } else {
                headTwo = [:]
            }
        } else if(count == 0){
            headOne = [:]; headTwo = [:]; headThree = [:]; headFour = [:]
        }
        
        headOne != [:] ? headerText += "\(headOne["key"] ?? "") : \(headOne["val"] ?? "")\n" : nil
        headTwo != [:] ? headerText += "\(headTwo["key"] ?? "") : \(headTwo["val"] ?? "")\n" : nil
        headThree != [:] ? headerText += "\(headThree["key"] ?? "") : \(headThree["val"] ?? "")\n" : nil
        headFour != [:] ? headerText += "\(headFour["key"] ?? "") : \(headFour["val"] ?? "")" : nil
        
        httpHeadersOutput.text = headerText
        httpHeaderKey.text = ""
        httpHeaderVal.text = ""
        
        UserDefaults.standard.set(sender.value, forKey: "headCount")
    }
    
    @IBAction func httpSendBtnPress(_ sender: UIButton) {
        let url: String = httpUrl.text ?? ""
        let body: String = httpBody.text ?? ""
        var bodyType: String = "TEXT"
        let bodyTypeIndex: Int = httpBodyType.selectedSegmentIndex
        var method: String = "GET"
        let methodIndex: Int = httpMethod.selectedSegmentIndex
        var jsonParseCheck = true
        
        switch methodIndex {
        case 0: method = "GET"
        case 1: method = "POST"
        case 2: method = "PUT"
        case 3: method = "DELETE"
        default: break
        }
        
        switch bodyTypeIndex {
        case 0: bodyType = "TEXT"
        case 1: bodyType = "JSON"
        default: break
        }
        
        httpSendBtn.isEnabled = false;
        if(verifyUrl(urlString: url)) {
            self.httpSendBtn.setTitle("...", for: .normal)
            do {
                var requestOutput: [String : Any] = [
                    "url": url,
                    "method": method
                ]
                var headerVals:String = "";
                
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = method
                
                if(headOne["key"] != nil && headOne["val"] != nil) {
                    request.setValue(headOne["val"], forHTTPHeaderField: headOne["key"] ?? "")
                    headerVals += "\(headOne["key"] ?? ""): \(headOne["val"] ?? "")"
                }
                if(headTwo["key"] != nil && headTwo["val"] != nil) {
                    request.setValue(headTwo["val"], forHTTPHeaderField: headTwo["key"] ?? "")
                    headerVals += ", \(headTwo["key"] ?? ""): \(headTwo["val"] ?? "")"
                }
                if(headThree["key"] != nil && headThree["val"] != nil) {
                    request.setValue(headThree["val"], forHTTPHeaderField: headThree["key"] ?? "")
                    headerVals += ", \(headThree["key"] ?? ""): \(headThree["val"] ?? "")"
                }
                if(headFour["key"] != nil && headFour["val"] != nil) {
                    request.setValue(headFour["val"], forHTTPHeaderField: headFour["key"] ?? "")
                    headerVals += ", \(headFour["key"] ?? ""): \(headFour["val"] ?? "")"
                }
                
                requestOutput["headers"] = headerVals;
                
                if(body != "") {
                    let bodyData = body.data(using: .utf8, allowLossyConversion: false)!
                    if(bodyType == "TEXT"){
                        request.httpBody = bodyData
                    } else {
//                        print("bodyData")
//                        print(bodyData)
                        
                        let data = body.data(using: .utf8)!
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]
                            {
                                print(jsonArray) // use the json here
                            } else {
                                print("bad json")
                                jsonParseCheck = false
                            }
                        } catch let error as NSError {
                            print(body)
                            print("ERROR")
                            print(error)
                            jsonParseCheck = false
                        }
                        
//                        do {
//                            let dict: [String: Any] = convertToDictionary(text: body.replacingOccurrences(of: "\\", with: "")) ?? [:]
////                            let jsonBody = try JSONSerialization.data(withJSONObject: dict)
////                            request.httpBody = jsonBody
//                            print("DICT")
//                            print(dict)
////                            print("jsonBody")
////                            print(jsonBody)
//                        } catch {
//                            print("json error: \(error.localizedDescription)")
//                            jsonParseCheck = false
//                        }
                    }
                    requestOutput["body"] = body
                }
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(stringify(json: requestOutput, prettyPrinted: true), forKey: "httpRequest")
                }
                
                if(jsonParseCheck) {
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            self.showResponseView(str:String(error!.localizedDescription))
                            print("error=\(String(describing: error))")
                            return
                        }
                        
    //                    let httpStatus = response as? HTTPURLResponse
    //                    let statusMsg: String = String(httpStatus!.statusCode)
    //                    print(httpStatus!)
                        
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
//                                print(json)
                                let output = stringify(json: json, prettyPrinted: true)
                                self.showResponseView(str:output)
                            }
                        } catch let error {
                            print(error.localizedDescription)
                            let str = String(decoding: data, as: UTF8.self)
                            self.showResponseView(str:str)
                        }
                    }
                    task.resume()
                } else {
                    self.httpSendBtn.setTitle("Invalid JSON", for: .normal)
                }
            }
        } else {
            self.httpSendBtn.setTitle("Invalid URL", for: .normal)
        }
        resetSendBtn()
    }
    
    //CUSTOM STYLING & GLOBAL FUNCS
    func showResponseView(str:String){
        DispatchQueue.main.async {
            UserDefaults.standard.set(str, forKey: "httpResponse")
            self.performSegue(withIdentifier: "httpResponseSegue", sender: self)
        }
    }
    func resetSendBtn(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.httpSendBtn.isEnabled = true;
            self.httpSendBtn.setTitle("Send", for: .normal)
        }
    }
}

class ResponseViewController: UIViewController {
    
    @IBOutlet var httpShareBtn: UIButton!
    @IBOutlet var requestText: UITextView!
    @IBOutlet var responseText: UITextView!
    @IBOutlet var responseCloseBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        requestText.text = UserDefaults.standard.string(forKey: "httpRequest") ?? ""
        responseText.text = UserDefaults.standard.string(forKey: "httpResponse") ?? ""
        
        print(UserDefaults.standard.string(forKey: "httpResponse") ?? "")
        setBtnStyle(btn: httpShareBtn, radius: 5.0, shadow: 0.0)
        setBtnStyle(btn: responseCloseBtn, radius: 5.0, shadow: 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //REQUEST AND RESPONSE POPOVER ACTIONS
    //share
    @IBAction func shareBtnPress(_ sender: UIButton) {
        let shareText = "REQUEST\n\n\(requestText.text ?? "")\n\n\nRESPONSE\n\n\(responseText.text ?? "")"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [shareText], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func responseClosePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
}

//GLOBAL FUNCS
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

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func verifyUrl(urlString: String?) -> Bool {
    guard let urlString = urlString,
        let url = URL(string: urlString) else {
            return false
    }
    
    return UIApplication.shared.canOpenURL(url)
}

func setBtnStyle(btn:UIButton, radius:Double, shadow:Double){
    btn.layer.cornerRadius = CGFloat(radius)
    btn.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1)
    btn.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
    btn.layer.borderWidth = 1
    btn.layer.shadowColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
    btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    btn.layer.shadowOpacity = 1
    btn.layer.shadowRadius = CGFloat(shadow)
}

func setSegmentStyle(seg:UISegmentedControl){
//    seg.layer.cornerRadius = CGFloat(5.0)
//    seg.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//    seg.layer.shadowColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25).cgColor
//    seg.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
//    seg.layer.shadowOpacity = 1.0
//    seg.layer.shadowRadius = 5.0
}

var headOne:[String:String] = [:]
var headTwo:[String:String] = [:]
var headThree:[String:String] = [:]
var headFour:[String:String] = [:]
