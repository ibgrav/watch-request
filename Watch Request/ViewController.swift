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
    @IBOutlet var httpSendBtn: UIButton!
    
    //HTTP REQUEST AND RESPONSE POPOVER
    @IBOutlet var requestText: UITextView!
    @IBOutlet var responseText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    //REQUEST AND RESPONSE POPOVER ACTIONS
    @IBAction func sendBtnPress(_ sender: UIButton) {
        let firstActivityItem = "Text you want"
        let secondActivityItem : NSURL = NSURL(string: "http//:urlyouwant")!
        // If you want to put an image
        let image : UIImage = UIImage(named: "image.jpg")!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.allZeros
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func responseClosePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
}

