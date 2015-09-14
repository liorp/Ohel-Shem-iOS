//
//  NewsSys.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/2/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import WebKit

class NewsSys: UIViewController, WKNavigationDelegate, SFSafariViewControllerDelegate {

    @IBOutlet weak var theWebView: UIView?

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

    /*func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(URL: request.URL!)
                vc.delegate = self
                presentViewController(vc, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.sharedApplication().openURL(request.URL!)
            }
            return false
        }

        return true
    }*/

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        defer {
            decisionHandler(WKNavigationActionPolicy.Allow)
        }
        if navigationAction.navigationType == WKNavigationType.LinkActivated {
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(URL: navigationAction.request.URL!)
                vc.delegate = self
                presentViewController(vc, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
            }
        }
    }

    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        defer {
            self.theWebView?.addSubview(webView)
        }

        //Dirty hack to scale to page properly
        let userscript = WKUserScript(source: "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);", injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
        let usercontroller = WKUserContentController()
        usercontroller.addUserScript(userscript)
        let config = WKWebViewConfiguration()
        config.userContentController = usercontroller

        let webView = WKWebView(frame: (self.theWebView?.frame)!, configuration: config)
        webView.navigationDelegate = self

        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            do {
                let news = try SchoolWebsiteDataManager.sharedInstance.GetNews(HTMLContent: true)
                let stringToShow = "<html> <head> <style>@import url(http://fonts.googleapis.com/earlyaccess/alefhebrew.css); a{text-decoration : none;} body{ direction: rtl; font-family: \"Alef Hebrew\",\"Helvetica Neue\",Helvetica,Arial,sans-serif; background-color: #FFFFFF;} .LBnews{font-size : 24px;} .LBnews_more{text-decoration : none; font-size : 80%;} </style> </head> " + "<body> <div style=\"text-align:right; text-decoration : none;\">" + news + "</div> </body> </html>"
                // do some task
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    webView.loadHTMLString(stringToShow, baseURL: NSURL(string: "http://ohel-shem.com/portal4/"))
                }
            } catch {
                print(error)
                let stringToShow = "קרתה שגיאה בתהליך ההתחברות לשרת"
                // do some task
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    webView.loadHTMLString(stringToShow, baseURL: NSURL(string: "http://ohel-shem.com/portal4/"))
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //self.theTextView?.text = SchoolWebsiteDataManager.sharedInstance.GetNews(HTMLContent: true)
        //self.theTextView?.font = UIFont(name: "Alef-Regular", size: 18)

        self.navigationController?.navigationBar.translucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.addLeftMenuButton()
    }
}