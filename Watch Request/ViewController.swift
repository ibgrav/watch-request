//
//  ViewController.swift
//  Watch Request
//
//  Created by Isaac Graves on 8/9/19.
//  Copyright © 2019 ibgrav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //LANDING PAGE
    @IBOutlet var toWatchBtn: UIButton!
    
    //HTTP REQUEST SETTINGS PAGE
    @IBOutlet var httpMethod: UISegmentedControl!
    @IBOutlet var httpUrl: UITextField!
    @IBOutlet var httpBodyType: UISegmentedControl!
    @IBOutlet var httpBody: UITextView!
    @IBOutlet var httpHeaderSelect: UISegmentedControl!
    @IBOutlet var httpHeaderKey: UITextField!
    @IBOutlet var httpHeaderVal: UITextField!
    @IBOutlet var httpShareBtn: UIButton!
    @IBOutlet var httpSendBtn: UIButton!
    
    //HTTP REQUEST AND RESPONSE POPOVER
    @IBOutlet var requestText: UITextView!
    @IBOutlet var responseText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(httpBody != nil) {
            httpBodyStyle()
        }
        
        if(requestText != nil && responseText != nil){
            requestText.text = outputData["request"]
            responseText.text = outputData["response"]
        }
    }
    
    //HTTP SETTINGS ACTIONS
    @IBAction func httpSendBtnPress(_ sender: UIButton) {
        let url: String = httpUrl.text ?? ""
        let body: String = httpBody.text ?? ""
        let headKey: String = httpHeaderKey.text ?? ""
        let headVal: String = httpHeaderVal.text ?? ""
        var method: String = "GET";
        let methodIndex: Int = httpMethod.selectedSegmentIndex;
        
        switch methodIndex {
        case 0: method = "GET"
        case 1: method = "POST"
        case 2: method = "PUT"
        case 3: method = "DELETE"
        default: break
        }
        
        httpSendBtn.isEnabled = false;
        if(verifyUrl(urlString: url)) {
            do {
                var requestOutput: [String : Any] = [
                    "URL": url,
                    "Method": method
                ]
                
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = method
                
                if(headKey != "" && headVal != "") {
                    request.setValue(headVal, forHTTPHeaderField: headKey)
                    requestOutput["Headers"] = [headKey: headVal]
                }
                if(body != "") {
                    request.httpBody = body.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    requestOutput["Body"] = body
                }
                
                DispatchQueue.main.async {
                    outputData["request"] = self.stringify(json: requestOutput, prettyPrinted: true)
                }
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        outputData["response"] = String(error!.localizedDescription)
                        print("error=\(String(describing: error))")
                        return
                    }
                    
                    let httpStatus = response as? HTTPURLResponse
//                    let statusMsg: String = String(httpStatus!.statusCode)
                    print(httpStatus!)
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            print(json)
                            let output = self.stringify(json: json, prettyPrinted: true)
                            outputData["response"] = output
                        }
                    } catch let error {
                        print(error.localizedDescription)
                        let str = String(decoding: data, as: UTF8.self)
                        outputData["response"] = str;
                    }
                }
                task.resume()
            }
        } else {
            outputData["response"] = "Invalid URL"
        }
        
        httpSendBtn.isEnabled = true;
    }
    
    //REQUEST AND RESPONSE POPOVER ACTIONS
    //share
    @IBAction func shareBtnPress(_ sender: UIButton) {
        let firstActivityItem = "Text you want"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func responseClosePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    //CUSTOM STYLING
    func httpBodyStyle(){
        httpBody.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    //GLOBAL FUNCTIONS
    func resetSendBtn(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.httpSendBtn.isEnabled = true;
            self.httpSendBtn.setTitle("Send", for: .normal)
        }
    }
    func verifyUrl(urlString: String?) -> Bool {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                return false
        }
        
        return UIApplication.shared.canOpenURL(url)
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
}

var outputData: [String:String] = [
    "request": "",
    "response": ""
]
