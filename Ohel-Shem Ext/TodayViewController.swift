//
//  TodayViewController.swift
//  Ohel-Shem Ext
//
//  Created by Lior Pollak on 12/31/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet var widgetLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDefaultsDidChange:", name: NSUserDefaultsDidChangeNotification, object: nil)
        widgetLabel?.textAlignment = NSTextAlignment.Right
        widgetLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "gotoMainApp"))
        widgetLabel?.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        self.updateLabel()

        completionHandler(NCUpdateResult.NewData)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ context in
            self.widgetLabel!.frame = CGRectMake(0, 0, size.width, size.height)
            }, completion: nil)
    }

    func userDefaultsDidChange(notification: NSNotification) {
        self.widgetPerformUpdateWithCompletionHandler{
            (result: NCUpdateResult) in
            println("got back: \(result)")
        }
    }

    func updateLabel(){
        var sharedDefaults = NSUserDefaults(suiteName: "group.LiorPollak.OhelShemExtensionSharingDefaults")
        if let text = sharedDefaults?.valueForKey("todayViewText") as? String {
            widgetLabel?.text = "בגדול, היום שלך נראה ככה: " + text//.stringByReplacingOccurrencesOfString("\n", withString: ", ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)//.substringToIndex(advance(text.endIndex, -2))
        } else {
            widgetLabel?.text = "גע לעדכון"
        }
        self.widgetLabel?.textColor = UIColor.whiteColor()
        self.widgetLabel?.sizeToFit()
        var currentSize = self.widgetLabel!.frame.size
        currentSize = self.widgetLabel!.sizeThatFits(currentSize)
        currentSize.height += 20
        self.preferredContentSize = currentSize
    }

    func gotoMainApp() {
        self.extensionContext?.openURL(NSURL(string: "OhelShem://")!, completionHandler:{(success: Bool) -> Void in
        })
    }
}
