//
//  InterfaceController.swift
//  Watch Request WatchKit Extension
//
//  Created by Isaac Graves on 8/9/19.
//  Copyright © 2019 ibgrav. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var sendBtn: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func sendBtnPress() {
        
    }
}
