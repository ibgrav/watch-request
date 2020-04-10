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
        
        self.sendBtn.setBackgroundColor(UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1))
        self.sendBtn.setTitle(globs["watchBtnTitle"] ?? "Send")
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
                    var reqOut:String = "url:\n\(url)\n"
                    var jsonOut:[String:Any] = ["url":url]
                    
                    reqOut += "\nmethod:    \(method)\n"
                    jsonOut["method"] = method;
                    
                    var headerVals:String = "";
                    var jsonHeaders:[String:String] = [:]
                    
                    var request = URLRequest(url: URL(string: url)!)
                    request.httpMethod = method
                    
                    if(globs["bodyHeadKey"] != "" && globs["bodyHeadVal"] != "") {
                        request.setValue(globs["bodyHeadVal"], forHTTPHeaderField: globs["bodyHeadKey"] ?? "")
                        headerVals += "\(globs["bodyHeadKey"] ?? ""): \(globs["bodyHeadVal"] ?? "")\n"
                        jsonHeaders[globs["bodyHeadKey"] ?? "bodyHeaderKey"] = globs["bodyHeadVal"]
                    }
                    if(globs["headOneKey"] != "" && globs["headOneVal"] != "") {
                        request.setValue(globs["headOneVal"], forHTTPHeaderField: globs["headOneKey"] ?? "")
                        headerVals += "\(globs["headOneKey"] ?? ""): \(globs["headOneVal"] ?? "")\n"
                        jsonHeaders[globs["headOneKey"] ?? "headOneKey"] = globs["headOneVal"]
                    }
                    if(globs["headTwoKey"] != "" && globs["headTwoVal"] != "") {
                        request.setValue(globs["headTwoVal"], forHTTPHeaderField: globs["headTwoKey"] ?? "")
                        headerVals += "\(globs["headTwoKey"] ?? ""): \(globs["headTwoVal"] ?? "")\n"
                        jsonHeaders[globs["headTwoKey"] ?? "headTwoKey"] = globs["headTwoVal"]
                    }
                    if(globs["headThreeKey"] != "" && globs["headThreeVal"] != "") {
                        request.setValue(globs["headThreeVal"], forHTTPHeaderField: globs["headThreeKey"] ?? "")
                        headerVals += "\(globs["headThreeKey"] ?? ""): \(globs["headThreeVal"] ?? "")\n"
                        jsonHeaders[globs["headThreeKey"] ?? "headThreeKey"] = globs["headThreeVal"]
                    }
                    if(globs["headFourKey"] != "" && globs["headFourVal"] != "") {
                        request.setValue(globs["headFourVal"], forHTTPHeaderField: globs["headFourKey"] ?? "")
                        headerVals += "\(globs["headFourKey"] ?? ""): \(globs["headFourVal"] ?? "")\n"
                        jsonHeaders[globs["headFourKey"] ?? "headFourKey"] = globs["headFourVal"]
                    }
                    
                    if(headerVals != ""){
                        reqOut += "\nheaders:\n\(headerVals)";
                    }
                    
                    jsonOut["headers"] = jsonHeaders
                    
                    if(body != "") {
                        request.httpBody = body.data(using: .utf8, allowLossyConversion: false)!
                        reqOut += "\nbody:\n\(body)";
                        jsonOut["body"] = body
                    }
                    
                    globs["httpRequest"] = reqOut
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            let err:String = String(error!.localizedDescription)
                            jsonOut["response"] = err
                            
                            self.showResponseView(str:String(error!.localizedDescription), code:999)
                            //SEND LOGS
                            self.sendLogs(message: jsonOut)
                            
                            return
                        }
                        
                        let httpStatus = response as? HTTPURLResponse
                        let statusMsg: Int = Int(httpStatus!.statusCode)
                        jsonOut["status"] = String(statusMsg)
                        
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                let output = stringify(json: json, prettyPrinted: true)
                                jsonOut["response"] = json
                                
                                self.showResponseView(str:output, code:statusMsg)
                                //SEND LOGS
                                self.sendLogs(message: jsonOut)
                            }
                        } catch let error {
                            print(error.localizedDescription)
                            let str = String(decoding: data, as: UTF8.self)
                            jsonOut["response"] = str
                            
                            self.showResponseView(str:str, code:statusMsg)
                            //SEND LOGS
                            self.sendLogs(message: jsonOut)
                        }
                    }
                    task.resume()
                }
            } else {
                vibrate(vib: .failure)
                self.sendBtn.setTitle("Missing URL");
                self.sendBtn.setBackgroundColor(UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.resetSendBtn()
                }
                self.sendLogs(message: ["error":"Invalid URL \(url)"])
            }
        }
    }
    
    //CUSTOM STYLING & GLOBAL FUNCS
    func sendLogs(message: [String:Any]) {
        let logPOST = globs["logPOST"] ?? ""
        let logURL = globs["logURL"] ?? ""
        let logKey = globs["logKey"] ?? ""
        let logVal = globs["logVal"] ?? ""
        
        if(logURL != "") {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let now = df.string(from: Date())
            
            var output = message;
            output["timestamp"] = now
            
            if(logURL != "") {
                let finalOut:[String:Any] = ["message":output]
                let logOut = stringify(json: finalOut, prettyPrinted: true)
                
                do {
                    var request:URLRequest;
                    if(logPOST == "true"){
                        request = URLRequest(url: URL(string: logURL)!)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        print("LOG OUT ------------------------------ ")
                        print(logOut)
                        print("END LOG OUT  ------------------------- ")
                        request.httpBody = logOut.data(using: .utf8, allowLossyConversion: false)!
                    } else {
                        var finalURL:String = "\(logURL)"
                        if logURL.contains("?") {
                            finalURL = "\(logURL)&app=watch-request&source=watch&status=\(message["status"] ?? "error")"
                        } else {
                            finalURL = "\(logURL)?app=watch-request&source=watch&status=\(message["status"] ?? "error")"
                        }
                        
                        request = URLRequest(url: URL(string: finalURL)!)
                        request.httpMethod = "GET"
                    }
                    
                    if(logKey != "" && logVal != ""){
                        request.setValue(logVal, forHTTPHeaderField: logKey)
                    }
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard error == nil else {
                            let err:String = String(error!.localizedDescription);
                            print("LOG ERR \(err)")
                            return
                        }
                        print("LOG SENT")
                    }
                    task.resume()
                }
            }
        }
    }
    
    func resetSendBtn(){
        self.sendBtn.setTitle(globs["watchBtnTitle"] ?? "Send")
        self.sendBtn.setBackgroundColor(UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1))
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
            self.sendBtnEnabled = true;
        } else {
            var btnMessage = "OKAY"
            
            if(code < 200) {
                self.sendBtn.setBackgroundColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0))
                vibrate(vib: .retry)
            } else if(code < 300) {
                self.sendBtn.setBackgroundColor(UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0))
                vibrate(vib: .success)
            } else if(code < 400) {
                self.sendBtn.setBackgroundColor(UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0))
                vibrate(vib: .failure)
                btnMessage = "ERROR"
            } else if(code < 500) {
                self.sendBtn.setBackgroundColor(UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0))
                vibrate(vib: .failure)
                btnMessage = "ERROR"
            } else {
                self.sendBtn.setBackgroundColor(UIColor(red: 0.8, green: 0.2, blue: 0.8, alpha: 1.0))
                vibrate(vib: .failure)
                btnMessage = "ERROR"
            }
            
            self.sendBtn.setTitle(btnMessage)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.resetSendBtn()
                self.sendBtnEnabled = true;
            }
        }
    }
    
    func vibrate(vib: WKHapticType){
        WKInterfaceDevice().play(vib)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            WKInterfaceDevice().play(vib)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                WKInterfaceDevice().play(vib)
//            }
//        }
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
            globs["watchBtnTitle"] = iPhoneContext["watchBtnTitle"] ?? "Send";
            globs["logPOST"] = iPhoneContext["logPOST"] ?? "";
            globs["logURL"] = iPhoneContext["logURL"] ?? "";
            globs["logKey"] = iPhoneContext["logKey"] ?? "";
            globs["logVal"] = iPhoneContext["logVal"] ?? "";
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
