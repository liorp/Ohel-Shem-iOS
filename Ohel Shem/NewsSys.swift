//
//  NewsSys.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/2/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

class NewsSys: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var theWebView: UIWebView?

    /*func getNews() {
        let data = NSString(contentsOfURL: NSURL(string: "http://ohel-shem.com/portal4/Archive.php?" + String(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue))!, encoding:NSUTF8StringEncoding , error: nil)

        // Parse a string and find an element.
        let document = HTMLDocument(string: data)
        let newsTable = document.firstNodeMatchingSelector("#MainBlock_Content")

        for node in newsTable.nodesMatchingSelector(".LBnews"){
            //News item
            self.theTextView!.text = self.theTextView!.text + (node.firstNodeMatchingSelector("div").textContent! as NSString).substringToIndex((node.firstNodeMatchingSelector("div").textContent! as NSString).length - 15) + "\n \n"
            //Hack because I should remove the פרטים נוספים
        }
    }*/

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }

        return true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let stringToShow = "<html> <head> <style>@import url(http://fonts.googleapis.com/earlyaccess/alefhebrew.css); a{text-decoration : none;} body{ direction: rtl; font-family: \"Alef Hebrew\",\"Helvetica Neue\",Helvetica,Arial,sans-serif; background-color: #FFFFFF;} .LBnews{font-size : 24px;} .LBnews_more{text-decoration : none; font-size : 80%;} </style> </head> " + "<body> <div style=\"text-align:right; text-decoration : none;\">" + SchoolWebsiteDataManager.sharedInstance.GetNews(HTMLContent: true) + "</div> </body> </html>"
            // do some task
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                let i = 0
                self.theWebView?.loadHTMLString(stringToShow, baseURL: NSURL(string: "http://ohel-shem.com/portal4/"))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.theWebView?.delegate = self

        //self.theTextView?.text = SchoolWebsiteDataManager.sharedInstance.GetNews(HTMLContent: true)
        //self.theTextView?.font = UIFont(name: "Alef-Regular", size: 18)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.addLeftMenuButton()
    }
}