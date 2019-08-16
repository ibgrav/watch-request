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
        let topTabVal = UserDefaults.standard.integer(forKey: "topTab")
        var data:[String:String] = [:]
        var bodyHead:[String:String] = ["key":"","val":""]
        
        switch topTabVal {
        case 0: data = req1
        case 1: data = req2
        case 2: data = req3
        case 3: data = req4
        default: break
        }
        
        switch data["bodyType"] {
        case "0": bodyHead = ["key":"","val":""]
        case "1": bodyHead = ["key":"Content-Type","val":"text/plain"]
        case "2": bodyHead = ["key":"Content-Type","val":"application/json"]
        case "3": bodyHead = ["key":"Content-Type","val":"application/xml"]
        default:break
        }
        
        let debugMode = UserDefaults.standard.string(forKey: "watchDebugMode") ?? ""
        
        if(verifyUrl(urlString: data["url"])) {
            
            if let validSession = session {
                //all items to pass to watch
                let iPhoneAppContext:[String:String] = [
                    "method": data["method"] ?? "",
                    "url": data["url"] ?? "",
                    "body": data["body"] ?? "",
                    "bodyHeadVal": bodyHead["val"] ?? "",
                    "bodyHeadKey": bodyHead["key"] ?? "",
                    "headOneVal": data["headOneVal"] ?? "",
                    "headTwoVal": data["headTwoVal"] ?? "",
                    "headThreeVal": data["headThreeVal"] ?? "",
                    "headFourVal": data["headFourVal"] ?? "",
                    "headOneKey": data["headOneKey"] ?? "",
                    "headTwoKey": data["headTwoKey"] ?? "",
                    "headThreeKey": data["headThreeKey"] ?? "",
                    "headFourKey": data["headFourKey"] ?? "",
                    "debugMode": debugMode
                    ]
                
                do {
                    //send to watch
                    try validSession.updateApplicationContext(iPhoneAppContext)
                    self.sendWatchBtn.setTitle("Ready!", for: .normal)
                    self.sendWatchBtn.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1)
                } catch {
                    self.sendWatchBtn.setTitle("Watch Error", for: .normal)
                    self.sendWatchBtn.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
                }
            }
        } else {
            self.sendWatchBtn.setTitle("Invalid URL!", for: .normal)
            self.sendWatchBtn.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
        }
        
        resetSendWatchBtn()
    }
    
    func resetSendWatchBtn(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.sendWatchBtn.isEnabled = true;
            self.sendWatchBtn.setTitle("Send to Watch", for: .normal)
            setBtnStyle(btn:self.sendWatchBtn, radius:20.0, shadow:5.0)
        }
    }
}

class InfoViewController: UIViewController {
    
    @IBOutlet var watchDebugSwitch: UISwitch!
    
    override func viewWillDisappear(_ animated: Bool) {
        if(watchDebugSwitch.isOn) {
            UserDefaults.standard.set("true", forKey: "watchDebugMode")
        } else {
            UserDefaults.standard.set("false", forKey: "watchDebugMode")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let debugMode:String = UserDefaults.standard.string(forKey: "watchDebugMode") ?? ""
        if(debugMode == "true") {
            watchDebugSwitch.isOn = true
        } else {
            watchDebugSwitch.isOn = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class RequestViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var httpMethod: UISegmentedControl!
    @IBOutlet var httpUrl: UITextField!
    @IBOutlet var httpBodyType: UISegmentedControl!
    @IBOutlet var httpBody: UITextView!
    @IBOutlet var httpHeaderKey: UITextField!
    @IBOutlet var httpHeaderVal: UITextField!
    @IBOutlet var httpSendBtn: UIButton!
    @IBOutlet var httpHeadersOutput: UITextView!
    @IBOutlet var httpHeadCounter: UIStepper!
    @IBOutlet var topTab: UISegmentedControl!
    
    override func viewWillDisappear(_ animated: Bool) {
        let tabBarVal:Int = topTab.selectedSegmentIndex
        UserDefaults.standard.set(topTab.selectedSegmentIndex, forKey: "topTab")
        
        if(tabBarVal == 0){
            req1["url"] = self.httpUrl.text
            req1["method"] = String(self.httpMethod.selectedSegmentIndex)
            req1["body"] = self.httpBody.text
            req1["bodyType"] = String(self.httpBodyType.selectedSegmentIndex)
            req1["headerKey"] = self.httpHeaderKey.text
            req1["headerVal"] = self.httpHeaderVal.text
            req1["headCount"] = String(self.httpHeadCounter.value)
            req1["headOneKey"] = headOne["key"]
            req1["headOneVal"] = headOne["val"]
            req1["headTwoKey"] = headTwo["key"]
            req1["headTwoVal"] = headTwo["val"]
            req1["headThreeKey"] = headThree["key"]
            req1["headThreeVal"] = headThree["val"]
            req1["headFourKey"] = headFour["key"]
            req1["headFourVal"] = headFour["val"]
        } else if(tabBarVal == 1){
            req2["url"] = self.httpUrl.text
            req2["method"] = String(self.httpMethod.selectedSegmentIndex)
            req2["body"] = self.httpBody.text
            req2["bodyType"] = String(self.httpBodyType.selectedSegmentIndex)
            req2["headerKey"] = self.httpHeaderKey.text
            req2["headerVal"] = self.httpHeaderVal.text
            req2["headCount"] = String(self.httpHeadCounter.value)
            req2["headOneKey"] = headOne["key"]
            req2["headOneVal"] = headOne["val"]
            req2["headTwoKey"] = headTwo["key"]
            req2["headTwoVal"] = headTwo["val"]
            req2["headThreeKey"] = headThree["key"]
            req2["headThreeVal"] = headThree["val"]
            req2["headFourKey"] = headFour["key"]
            req2["headFourVal"] = headFour["val"]
        } else if(tabBarVal == 2){
            req3["url"] = self.httpUrl.text
            req3["method"] = String(self.httpMethod.selectedSegmentIndex)
            req3["body"] = self.httpBody.text
            req3["bodyType"] = String(self.httpBodyType.selectedSegmentIndex)
            req3["headerKey"] = self.httpHeaderKey.text
            req3["headerVal"] = self.httpHeaderVal.text
            req3["headCount"] = String(self.httpHeadCounter.value)
            req3["headOneKey"] = headOne["key"]
            req3["headOneVal"] = headOne["val"]
            req3["headTwoKey"] = headTwo["key"]
            req3["headTwoVal"] = headTwo["val"]
            req3["headThreeKey"] = headThree["key"]
            req3["headThreeVal"] = headThree["val"]
            req3["headFourKey"] = headFour["key"]
            req3["headFourVal"] = headFour["val"]
        } else if(tabBarVal == 3){
            req4["url"] = self.httpUrl.text
            req4["method"] = String(self.httpMethod.selectedSegmentIndex)
            req4["body"] = self.httpBody.text
            req4["bodyType"] = String(self.httpBodyType.selectedSegmentIndex)
            req4["headerKey"] = self.httpHeaderKey.text
            req4["headerVal"] = self.httpHeaderVal.text
            req4["headCount"] = String(self.httpHeadCounter.value)
            req4["headOneKey"] = headOne["key"]
            req4["headOneVal"] = headOne["val"]
            req4["headTwoKey"] = headTwo["key"]
            req4["headTwoVal"] = headTwo["val"]
            req4["headThreeKey"] = headThree["key"]
            req4["headThreeVal"] = headThree["val"]
            req4["headFourKey"] = headFour["key"]
            req4["headFourVal"] = headFour["val"]
        }
        
        UserDefaults.standard.set(req1, forKey: "req1")
        UserDefaults.standard.set(req2, forKey: "req2")
        UserDefaults.standard.set(req3, forKey: "req3")
        UserDefaults.standard.set(req4, forKey: "req4")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //CLOSE KEYBOARD ON TAP
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let topTabVal:Int = UserDefaults.standard.integer(forKey: "topTab")
        topTab.selectedSegmentIndex = topTabVal
        
        if(UserDefaults.standard.dictionary(forKey: "req1") != nil){
            req1 = UserDefaults.standard.dictionary(forKey: "req1") as! [String : String]
        }
        if(UserDefaults.standard.dictionary(forKey: "req2") != nil){
            req2 = UserDefaults.standard.dictionary(forKey: "req2") as! [String : String]
        }
        if(UserDefaults.standard.dictionary(forKey: "req3") != nil){
            req3 = UserDefaults.standard.dictionary(forKey: "req3") as! [String : String]
        }
        if(UserDefaults.standard.dictionary(forKey: "req4") != nil){
            req4 = UserDefaults.standard.dictionary(forKey: "req4") as! [String : String]
        }
        
        if(topTabVal == 0){
            setReqData(data:req1)
        } else if(topTabVal == 1){
            setReqData(data:req2)
        } else if(topTabVal == 2){
            setReqData(data:req3)
        } else if(topTabVal == 3){
            setReqData(data:req4)
        } else {
            setReqData(data:req1)
        }
        
        updateHeaderOutput()
        
        httpBody.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        httpBody.layer.borderWidth = 0.5
        httpBody.layer.cornerRadius = 6.0
        
//        topTab.tintColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1)
        
        setBtnStyle(btn: httpSendBtn, radius:5.0, shadow:0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.httpUrl.delegate = self
        self.httpHeaderKey.delegate = self
        self.httpHeaderVal.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func setReqData(data:[String:String]){
        self.httpUrl.text = data["url"]
        self.httpMethod.selectedSegmentIndex = Int(data["method"]!) ?? 0
        self.httpBody.text = data["body"]
        self.httpBodyType.selectedSegmentIndex = Int(data["bodyType"]!) ?? 0
        self.httpHeaderKey.text = data["headerKey"]
        self.httpHeaderVal.text = data["headerVal"]
        self.httpHeadCounter.value = Double(data["headCount"]!) ?? 0
        
        switch self.httpBodyType.selectedSegmentIndex {
        case 0: bodyHeader = ["key":"","val":""]
        case 1: bodyHeader = ["key":"Content-Type","val":"text/plain"]
        case 2: bodyHeader = ["key":"Content-Type","val":"application/json"]
        case 3: bodyHeader = ["key":"Content-Type","val":"application/xml"]
        default: break
        }

        headOne["key"] = data["headOneKey"]
        headTwo["key"] = data["headTwoKey"]
        headThree["key"] = data["headThreeKey"]
        headFour["key"] = data["HeadFourKey"]

        headOne["val"] = data["headOneVal"]
        headTwo["val"] = data["headTwoVal"]
        headThree["val"] = data["headThreeVal"]
        headFour["val"] = data["HeadFourVal"]
    }
    
    //HTTP SETTINGS ACTIONS
    @IBAction func tabChange(_ sender: UISegmentedControl) {
        let lastTab = UserDefaults.standard.integer(forKey: "topTab")
        if(lastTab == 0){
            req1["url"] = self.httpUrl.text
            req1["method"] = String(self.httpMethod.selectedSegmentIndex)
            req1["body"] = self.httpBody.text
            req1["bodyType"] = String(self.httpBodyType.selectedSegmentIndex)
            req1["headerKey"] = self.httpHeaderKey.text
            req1["headerVal"] = self.httpHeaderVal.text
            req1["headCount"] = String(self.httpHeadCounter.value)
            req1["headOneKey"] = headOne["key"]
            req1["headOneVal"] = headOne["val"]
            req1["headTwoKey"] = headTwo["key"]
            req1["headTwoVal"] = headTwo["val"]
            req1["headThreeKey"] = headThree["key"]
            req1["headThreeVal"] = headThree["val"]
            req1["headFourKey"] = headFour["key"]
            req1["headFourVal"] = headFour["val"]
        } else if(lastTab == 1){
            req2["url"] = self.httpUrl.text
            req2["method"] = String(self.httpMethod.selectedSegmentIndex)
            req2["body"] = self.httpBody.text
            req2["bodyType"] = String(self.httpBodyType.selectedSegmentIndex)
            req2["headerKey"] = self.httpHeaderKey.text
            req2["headerVal"] = self.httpHeaderVal.text
            req2["headCount"] = String(self.httpHeadCounter.value)
            req2["headOneKey"] = headOne["key"]
            req2["headOneVal"] = headOne["val"]
            req2["headTwoKey"] = headTwo["key"]
            req2["headTwoVal"] = headTwo["val"]
            req2["headThreeKey"] = headThree["key"]
            req2["headThreeVal"] = headThree["val"]
            req2["headFourKey"] = headFour["key"]
            req2["headFourVal"] = headFour["val"]
        } else if(lastTab == 2){
            req3["url"] = self.httpUrl.text
            req3["method"] = String(self.httpMethod.selectedSegmentIndex)
            req3["body"] = self.httpBody.text
            req3["bodyType"] = String(self.httpBodyType.selectedSegmentIndex)
            req3["headerKey"] = self.httpHeaderKey.text
            req3["headerVal"] = self.httpHeaderVal.text
            req3["headCount"] = String(self.httpHeadCounter.value)
            req3["headOneKey"] = headOne["key"]
            req3["headOneVal"] = headOne["val"]
            req3["headTwoKey"] = headTwo["key"]
            req3["headTwoVal"] = headTwo["val"]
            req3["headThreeKey"] = headThree["key"]
            req3["headThreeVal"] = headThree["val"]
            req3["headFourKey"] = headFour["key"]
            req3["headFourVal"] = headFour["val"]
        } else if(lastTab == 3){
            req4["url"] = self.httpUrl.text
            req4["method"] = String(self.httpMethod.selectedSegmentIndex)
            req4["body"] = self.httpBody.text
            req4["bodyType"] = String(self.httpBodyType.selectedSegmentIndex)
            req4["headerKey"] = self.httpHeaderKey.text
            req4["headerVal"] = self.httpHeaderVal.text
            req4["headCount"] = String(self.httpHeadCounter.value)
            req4["headOneKey"] = headOne["key"]
            req4["headOneVal"] = headOne["val"]
            req4["headTwoKey"] = headTwo["key"]
            req4["headTwoVal"] = headTwo["val"]
            req4["headThreeKey"] = headThree["key"]
            req4["headThreeVal"] = headThree["val"]
            req4["headFourKey"] = headFour["key"]
            req4["headFourVal"] = headFour["val"]
        }
        
        if(sender.selectedSegmentIndex == 0){
            setReqData(data:req1)
        } else if(sender.selectedSegmentIndex == 1){
            setReqData(data:req2)
        } else if(sender.selectedSegmentIndex == 2){
            setReqData(data:req3)
        } else if(sender.selectedSegmentIndex == 3){
            setReqData(data:req4)
        } else {
            setReqData(data:req1)
        }
        
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "topTab")
        
        updateHeaderOutput()
    }
    
    @IBAction func bodyTypeChanged(_ sender: UISegmentedControl) {
        let currentVal = sender.selectedSegmentIndex
        
        print(currentVal)
        
        switch currentVal {
        case 0: bodyHeader = ["key":"","val":""]
        case 1: bodyHeader = ["key":"Content-Type","val":"text/plain"]
        case 2: bodyHeader = ["key":"Content-Type","val":"application/json"]
        case 3: bodyHeader = ["key":"Content-Type","val":"application/xml"]
        default: break
        }
        
        updateHeaderOutput()
    }
    
    @IBAction func headerCount(_ sender: UIStepper) {
        let count = Double(sender.value);
        var headCheck:Bool = true;
        let prevCount = UserDefaults.standard.double(forKey: "headCount")
        
        if(httpHeaderKey.text?.isEmpty ?? true || httpHeaderVal.text?.isEmpty ?? true){
            headCheck = false;
        }
        print("httpHeaderKey.text?.isEmpty ?? true")
        print(httpHeaderKey.text?.isEmpty ?? true)
        print("httpHeaderVal.text?.isEmpty ?? true")
        print(httpHeaderVal.text?.isEmpty ?? true)
        
        if(count == 4){
            if(headCheck){
                headFour["key"] = httpHeaderKey.text ?? ""
                headFour["val"] = httpHeaderVal.text ?? ""
            } else {
                sender.value -= 1.0;
                headFour = ["key":"","val":""]
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
                headFour = ["key":"","val":""]
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
                headThree = ["key":"","val":""]
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
                headTwo = ["key":"","val":""]
            }
        } else if(count == 0){
            headOne = ["key":"","val":""]
            headTwo = ["key":"","val":""]
            headThree = ["key":"","val":""]
            headFour = ["key":"","val":""]
        }
        
        updateHeaderOutput()
        
        if(headCheck){
            httpHeaderKey.text = ""
            httpHeaderVal.text = ""
        }
        
        UserDefaults.standard.set(sender.value, forKey: "headCount")
    }
    
    @IBAction func httpSendBtnPress(_ sender: UIButton) {
        let url: String = httpUrl.text ?? ""
        let body: String = httpBody.text ?? ""
        var method: String = "GET"
        let methodIndex: Int = httpMethod.selectedSegmentIndex
        
        switch methodIndex {
        case 0: method = "GET"
        case 1: method = "POST"
        case 2: method = "PUT"
        case 3: method = "DELETE"
        default: break
        }
        
        httpSendBtn.isEnabled = false;
        if(verifyUrl(urlString: url)) {
            self.httpSendBtn.setTitle("...", for: .normal)
            do {
                var reqOut:String = "url:\n\(url)\n"
                reqOut += "\nmethod:    \(method)\n"
                var headerVals:String = "";
                
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = method
                
                if(bodyHeader["key"] != "" && bodyHeader["val"] != "") {
                    request.setValue(bodyHeader["val"], forHTTPHeaderField: bodyHeader["key"] ?? "")
                    headerVals += "\(bodyHeader["key"] ?? ""): \(bodyHeader["val"] ?? "")\n"
                }
                if(headOne["key"] != "" && headOne["val"] != "") {
                    request.setValue(headOne["val"], forHTTPHeaderField: headOne["key"] ?? "")
                    headerVals += "\(headOne["key"] ?? ""): \(headOne["val"] ?? "")\n"
                }
                if(headTwo["key"] != "" && headTwo["val"] != "") {
                    request.setValue(headTwo["val"], forHTTPHeaderField: headTwo["key"] ?? "")
                    headerVals += ", \(headTwo["key"] ?? ""): \(headTwo["val"] ?? "")\n"
                }
                if(headThree["key"] != "" && headThree["val"] != "") {
                    request.setValue(headThree["val"], forHTTPHeaderField: headThree["key"] ?? "")
                    headerVals += ", \(headThree["key"] ?? ""): \(headThree["val"] ?? "")\n"
                }
                if(headFour["key"] != "" && headFour["val"] != "") {
                    request.setValue(headFour["val"], forHTTPHeaderField: headFour["key"] ?? "")
                    headerVals += ", \(headFour["key"] ?? ""): \(headFour["val"] ?? "")\n"
                }
                
                if(headerVals != "") {
                    reqOut += "\nheaders:\n\(headerVals)";
                }
                
                if(body != "") {
                    request.httpBody = body.data(using: .utf8, allowLossyConversion: false)!
                    reqOut += "\nbody:\n\(body)";
                }
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(reqOut, forKey: "httpRequest")
                }
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        self.showResponseView(str:String(error!.localizedDescription), code:999)
                        self.resetSendBtn()
                        print("error=\(String(describing: error))")
                        return
                    }
                    
                    let httpStatus = response as? HTTPURLResponse
                    let statusMsg: Int = Int(httpStatus!.statusCode)
                    print("STATUS MSG")
                    print(statusMsg)
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            let output = stringify(json: json, prettyPrinted: true)
                            self.showResponseView(str:output, code:statusMsg)
                            self.resetSendBtn()
                        }
                    } catch let error {
                        print(error.localizedDescription)
                        let str = String(decoding: data, as: UTF8.self)
                        self.showResponseView(str:str, code:statusMsg)
                        self.resetSendBtn()
                    }
                }
                task.resume()
            }
        } else {
            self.httpSendBtn.setTitle("Invalid URL", for: .normal)
            resetSendBtn()
        }
    }
    
    //CUSTOM STYLING & GLOBAL FUNCS
    func showResponseView(str:String, code:Int){
        DispatchQueue.main.async {
            UserDefaults.standard.set(str, forKey: "httpResponse")
            UserDefaults.standard.set(code, forKey: "httpCode")
            self.performSegue(withIdentifier: "httpResponseSegue", sender: self)
        }
    }
    func resetSendBtn(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.httpSendBtn.isEnabled = true;
            self.httpSendBtn.setTitle("Send", for: .normal)
        }
    }
    func updateHeaderOutput(){
        var headerText:String = ""
        
        if(headFour == [:]){
            headFour = ["key":"","val":""]
        }
        
        bodyHeader != ["key":"","val":""] ? headerText += "\(bodyHeader["key"] ?? "") : \(bodyHeader["val"] ?? "")\n" : nil
        headOne != ["key":"","val":""] ? headerText += "\(headOne["key"] ?? "") : \(headOne["val"] ?? "")\n" : nil
        headTwo != ["key":"","val":""] ? headerText += "\(headTwo["key"] ?? "") : \(headTwo["val"] ?? "")\n" : nil
        headThree != ["key":"","val":""] ? headerText += "\(headThree["key"] ?? "") : \(headThree["val"] ?? "")\n" : nil
        headFour != ["key":"","val":""] ? headerText += "\(headFour["key"] ?? "") : \(headFour["val"] ?? "")" : nil
        
        httpHeadersOutput.text = headerText
    }
}

class ResponseViewController: UIViewController {
    
    @IBOutlet var httpShareBtn: UIButton!
    @IBOutlet var requestText: UITextView!
    @IBOutlet var responseText: UITextView!
    @IBOutlet var responseCloseBtn: UIButton!
    @IBOutlet var responseCode: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        requestText.text = UserDefaults.standard.string(forKey: "httpRequest") ?? ""
        responseText.text = UserDefaults.standard.string(forKey: "httpResponse") ?? ""
        let httpCode = UserDefaults.standard.integer(forKey: "httpCode")
        
        if(httpCode == 999){
            responseCode.text = "ERR"
        } else {
            responseCode.text = String(httpCode)
        }
        
        if(httpCode < 200) {
            responseCode.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.8, alpha: 1.0)
        } else if(httpCode < 300) {
            responseCode.textColor = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        } else if(httpCode < 400) {
            responseCode.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        } else if(httpCode < 500) {
            responseCode.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        } else {
            responseCode.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        
        print(UserDefaults.standard.string(forKey: "httpResponse") ?? "")
        setBtnStyle(btn: httpShareBtn, radius: 5.0, shadow: 0.0)
        setBtnStyle(btn: responseCloseBtn, radius: 5.0, shadow: 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scroll outputs to top
        requestText.setContentOffset(.zero, animated: true)
        responseText.setContentOffset(.zero, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //scroll outputs to top
        requestText.setContentOffset(.zero, animated: true)
        responseText.setContentOffset(.zero, animated: true)
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
//    btn.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
//    btn.layer.borderWidth = 0
//    btn.layer.shadowColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
//    btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//    btn.layer.shadowOpacity = 1
//    btn.layer.shadowRadius = CGFloat(shadow)
}

var bodyHeader:[String:String] = ["key":"","val":""]
var headOne:[String:String] = ["key":"","val":""]
var headTwo:[String:String] = ["key":"","val":""]
var headThree:[String:String] = ["key":"","val":""]
var headFour:[String:String] = ["key":"","val":""]

var req1:[String:String] = [
    "url":"",
    "method":"0",
    "body":"",
    "bodyType":"0",
    "headerKey":"",
    "headerVal":"",
    "headCount":"0",
    "headOneKey":"",
    "headOneVal":"",
    "headTwoKey":"",
    "headTwoVal":"",
    "headThreeKey":"",
    "headThreeVal":"",
    "headFourKey":"",
    "headFourVal":""
]
var req2:[String:String] = [
    "url":"",
    "method":"0",
    "body":"",
    "bodyType":"0",
    "headerKey":"",
    "headerVal":"",
    "headCount":"0",
    "headOneKey":"",
    "headOneVal":"",
    "headTwoKey":"",
    "headTwoVal":"",
    "headThreeKey":"",
    "headThreeVal":"",
    "headFourKey":"",
    "headFourVal":""
]
var req3:[String:String] = [
    "url":"",
    "method":"0",
    "body":"",
    "bodyType":"0",
    "headerKey":"",
    "headerVal":"",
    "headCount":"0",
    "headOneKey":"",
    "headOneVal":"",
    "headTwoKey":"",
    "headTwoVal":"",
    "headThreeKey":"",
    "headThreeVal":"",
    "headFourKey":"",
    "headFourVal":""
]
var req4:[String:String] = [
    "url":"",
    "method":"0",
    "body":"",
    "bodyType":"0",
    "headerKey":"",
    "headerVal":"",
    "headCount":"0",
    "headOneKey":"",
    "headOneVal":"",
    "headTwoKey":"",
    "headTwoVal":"",
    "headThreeKey":"",
    "headThreeVal":"",
    "headFourKey":"",
    "headFourVal":""
]
