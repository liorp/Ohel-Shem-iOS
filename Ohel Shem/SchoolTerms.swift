//
//  SchoolTerms.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/31/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class SchoolTerms: UIViewController {

    @IBOutlet weak var terms: UIView?

    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        //It seems that you've discovered an easter egg!
        /*if (motion == UIEventSubtype.MotionShake || event.subtype == UIEventSubtype.MotionShake){
            let saveAlert = UIAlertController(title: "שמואל קינן הוא המלך שלי", message: "אני מאשר את קבלת עול מלכותו של מלך המשיח שמואל קינן", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "כן", style: .Cancel) { (action) in
            }
            saveAlert.addAction(cancelAction)

            let OKAction = UIAlertAction(title: "כן", style: .Default) { (action) in
            }
            saveAlert.addAction(OKAction)

            self.presentViewController(saveAlert, animated: true) {
                // ...
            }
        }*/
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.addLeftMenuButton()
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        self.navigationController?.navigationBar.translucent = false
        //terms! = SchoolWebsiteDataManager.sharedInstance.GetTerms()

        let termsURL = NSURL(string: "http://www.ohel-shem.com/portal4/files/files/Ohel_Shem_Yedion_2014_Hagaha3.pdf")
        let theRequest = NSURLRequest(URL: termsURL!)
        //theRequest.cachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad


        if (NSClassFromString("WKWebView") != nil) {
            let config = WKWebViewConfiguration()
            let terms8 = WKWebView(frame: terms!.frame, configuration: config)
            self.view.addSubview(terms8)
            terms8.loadRequest(theRequest)
        }
        else {
            let terms7 = UIWebView(frame: terms!.frame)
            self.view.addSubview(terms7)
            terms7.loadRequest(theRequest)
            terms7.scalesPageToFit = true
        }
    }
}