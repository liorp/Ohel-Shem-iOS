//
//  ViewController.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import UIKit

class MainViewController: AMSlideMenuMainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        /*let store = NSUbiquitousKeyValueStore.defaultStore()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateKVStoreItems:"), name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: store)
        store.synchronize()*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*func updateKVStoreItems(notification: NSNotification) {
        // Get the list of keys that changed.
        let userInfo: NSDictionary = notification.userInfo!
        let reasonForChange: NSNumber = userInfo.objectForKey(NSUbiquitousKeyValueStoreChangeReasonKey) as NSNumber
        var reason:NSInteger = -1

        // If a reason could not be determined, do not update anything.
        if (reasonForChange.stringValue.isEmpty) {return}

        // Update only for changes from the server.
        reason = reasonForChange.integerValue
        if ((reason == NSUbiquitousKeyValueStoreServerChange) ||
            (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
                // If something is changing externally, get the changes
                // and update the corresponding keys locally.
                var changedKeys: NSArray = userInfo.objectForKey(NSUbiquitousKeyValueStoreChangedKeysKey) as NSArray
                let store = NSUbiquitousKeyValueStore.defaultStore
                var userDefaults = NSUserDefaults.standardUserDefaults

                // This loop assumes you are using the same key names in both
                // the user defaults database and the iCloud key-value store
                for key in changedKeys {
                    var value: AnyObject? = store().objectForKey(key as String)
                    userDefaults().setObject(value, forKey: key as String)
                }
        }
    }*/

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func configureLeftMenuButton(button: UIButton!) {
        var frame = button.frame
        frame = CGRectMake(0, 0, 25, 20)
        button.frame = frame
        button.backgroundColor = UIColor.clearColor()
        button.setImage(UIImage(named: "list23.png"), forState: UIControlState.Normal)
    }

    override func segueIdentifierForIndexPathInLeftMenu(indexPath: NSIndexPath!) -> String! {
        var theSegue:String!
        switch (indexPath!.row) {
        case 0:
            theSegue = "toMainPage"
            break
        case 1:
            theSegue = "toChanges"
            break
        case 2:
            theSegue = "toHour"
            break
        case 3:
            theSegue = "toBell"
            break
        // FIX: This should be updated to match the latest version of test system
        case 4:
            theSegue = "toTest"
            break
        case 5:
            theSegue = "toNews"
            break
        case 6:
            theSegue = "toTerms"
            break
        case 7:
            theSegue = "toAbout"
            break
        case 8:
            theSegue = "toSettings"
            break
        default:
            theSegue = "toMainPage"
            break
        }
        return theSegue
    }

    override func leftMenuWidth() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            return UIScreen.mainScreen().bounds.width / 1.5
        } else {
            return UIScreen.mainScreen().bounds.width / 2.5
        }
    }

    override func deepnessForLeftMenu() -> Bool {
        return false
    }
}

