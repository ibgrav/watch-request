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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    @IBOutlet var sendWatchBtn: UIButton!
    @IBAction func sendWatchPress(_ sender: UIButton) {
        sendWatchBtn.isEnabled = false
        
        
        
        let method = UserDefaults.standard.string(forKey: "method") ?? ""
        let url = UserDefaults.standard.string(forKey: "url") ?? ""
        let body = UserDefaults.standard.string(forKey: "body") ?? ""
        let bodyType = UserDefaults.standard.string(forKey: "body") ?? ""
        let headKey = UserDefaults.standard.string(forKey: "headKey") ?? ""
        let headVal = UserDefaults.standard.string(forKey: "headVal") ?? ""
        
        if(verifyUrl(urlString: url)) {
            
            if let validSession = session {
                //all items to pass to watch
                let iPhoneAppContext:[String:String] = [
                    "method": method,
                    "url": url,
                    "body": body,
                    "bodyType": bodyType,
                    "headKey": headKey,
                    "headVal": headVal
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
        UserDefaults.standard.set(httpHeaderKey.text, forKey: "headKey")
        UserDefaults.standard.set(httpHeaderVal.text, forKey: "headVal")
        UserDefaults.standard.set(methodText, forKey: "method")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let url = UserDefaults.standard.string(forKey: "url") ?? ""
        let body = UserDefaults.standard.string(forKey: "body") ?? ""
        let bodyType = UserDefaults.standard.string(forKey: "body") ?? ""
        let headKey = UserDefaults.standard.string(forKey: "headKey") ?? ""
        let headVal = UserDefaults.standard.string(forKey: "headVal") ?? ""
        let method = UserDefaults.standard.string(forKey: "method") ?? ""
        
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
        httpSendBtn.layer.cornerRadius = 6
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //HTTP SETTINGS ACTIONS
    
    @IBAction func headerCount(_ sender: UIStepper) {
        if(headers.count < Int(sender.value)){
            if(httpHeaderKey.text != "" && httpHeaderVal.text != ""){
                headers.append(["key":httpHeaderKey.text ?? "", "val":httpHeaderVal.text ?? ""])
                httpHeaderKey.text = ""
                httpHeaderVal.text = ""
            } else {
                sender.value -= 1.0;
            }
        } else {
            headers.remove(at: headers.count - 1)
        }
        print(headers)
        var headerText = ""
        for header in headers {
            headerText += "\(header["key"] ?? "") : \(header["val"] ?? "")\n"
        }
        httpHeadersOutput.text = headerText
    }
    
    @IBAction func httpSendBtnPress(_ sender: UIButton) {
        let url: String = httpUrl.text ?? ""
        let body: String = httpBody.text ?? ""
        let headKey: String = httpHeaderKey.text ?? ""
        let headVal: String = httpHeaderVal.text ?? ""
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
                var requestOutput: [String : Any] = [
                    "url": url,
                    "method": method
                ]
                
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = method
                
                if(headKey != "" && headVal != "") {
                    request.setValue(headVal, forHTTPHeaderField: headKey)
                    requestOutput["headers"] = [headKey: headVal]
                }
                if(body != "") {
                    request.httpBody = body.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    requestOutput["body"] = body
                }
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(stringify(json: requestOutput, prettyPrinted: true), forKey: "httpRequest")
                }
                
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
                            print(json)
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
    
    override func viewWillAppear(_ animated: Bool) {
        requestText.text = UserDefaults.standard.string(forKey: "httpRequest") ?? ""
        responseText.text = UserDefaults.standard.string(forKey: "httpResponse") ?? ""
        
        print(UserDefaults.standard.string(forKey: "httpResponse") ?? "")
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

func verifyUrl(urlString: String?) -> Bool {
    guard let urlString = urlString,
        let url = URL(string: urlString) else {
            return false
    }
    
    return UIApplication.shared.canOpenURL(url)
}

var headers:[[String:String]] = []
