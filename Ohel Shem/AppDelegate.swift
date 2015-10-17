//
//  AppDelegate.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Siren
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var j = 0

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {        Fabric.with([Crashlytics.self()])
        let branch = Branch.getInstance()
        branch.initSessionWithLaunchOptions(launchOptions) { (params, error) -> Void in
            print("Deep link data: \(params.description)")
        }
        //application.unregisterForRemoteNotifications()
        /*for family in UIFont.familyNames()
        {
        print(family)

        for name in UIFont.fontNamesForFamilyName((family as NSString))
        {
        print(name)
        }
        }*/

        // Override point for customization after application launch.


        if (application.applicationIconBadgeNumber > 0) {
            application.applicationIconBadgeNumber = 0
        }


        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil))

        let font : UIFont? = UIFont(name: "Alef-Bold", size: 22)

        UILabel.appearance().font = UIFont(name: "Alef-Regular", size: 18)
        UITextView.appearance().font = UIFont(name: "Alef-Regular", size: 18)
        UITextField.appearance().font = UIFont(name: "Alef-Regular", size: 16)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : font!]

        /*if let _: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("studentName") {

        } else {
        NSUserDefaults.standardUserDefaults().setValue("ליאור", forKey: "studentName")
        }

        if let _: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("classNum") {

        } else {
        NSUserDefaults.standardUserDefaults().setValue("4", forKey: "classNum")
        }

        if let _: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("layerNum") {

        } else {
        NSUserDefaults.standardUserDefaults().setValue("12", forKey: "layerNum")
        }*/

        // Siren code should go below window?.makeKeyAndVisible()

        // Siren is a singleton
        let siren = Siren.sharedInstance

        // Required: Your app's iTunes App Store ID
        siren.appID = "956866498"

        // Required on iOS 8: The controller to present the alert from (usually the UIWindow's rootViewController)
        //siren.presentingViewController = window?.rootViewController

        // Optional: Defaults to .Option
        siren.alertType = SirenAlertType.Option

        /*
        Replace .Immediately with .Daily or .Weekly to specify a maximum daily or weekly frequency for version
        checks.
        */
        siren.checkVersion(.Weekly)

        return true
    }

    /*func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    NSUserDefaults.standardUserDefaults().setValue(deviceToken, forKey: "deviceToken")
    let request = NSMutableURLRequest(URL: NSURL(string: "https://google.com")!)
    let session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"

    var token = NSString(format: "%@", deviceToken)

    token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
    token = token.stringByReplacingOccurrencesOfString(">", withString: "")
    token = token.stringByReplacingOccurrencesOfString("<", withString: "")

    let params = ["deviceToken":String(token)] as Dictionary<String, String>

    do {
    request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
    } catch {
    print(error)
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
    print("Response: \(response)")
    let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
    print("Body: \(strData)")
    do {
    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
    // The JSONObjectWithData constructor didn't return an error. But, we should still
    // check and make sure that json has a value using optional binding.
    if let parseJSON = json {
    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
    let success = parseJSON["success"] as? Int
    print("Succes: \(success)")
    } else {
    // Woa, okay the json object was nil, something went wrong. Maybe the server isn't running?
    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
    print("Error could not parse JSON: \(jsonStr)")
    }
    } catch {
    print(error)
    }
    })

    task.resume()

    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print(error)
    }*/

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print(UIApplication.sharedApplication().scheduledLocalNotifications?.count)

        if UIApplication.sharedApplication().scheduledLocalNotifications?.count > 1 {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        } else if UIApplication.sharedApplication().scheduledLocalNotifications?.count == 0 {

            let localNotification = UILocalNotification()

            let date = NSCalendar.currentCalendar().dateBySettingHour(21, minute: 03, second: 00, ofDate: NSDate(timeIntervalSinceNow: 0), options: NSCalendarOptions.MatchFirst)

            localNotification.alertBody = "השינויים התעדכנו. רוצה לבדוק?"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.applicationIconBadgeNumber = 1
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.alertAction = "כן!"
            localNotification.repeatInterval = NSCalendarUnit.Day
            localNotification.fireDate = date

            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSURLCache.sharedURLCache().removeAllCachedResponses() //Clears the cache
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //Siren.sharedInstance.checkVersion(.Immediately)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //Siren.sharedInstance.checkVersion(.Daily)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let ret = Branch.getInstance().handleDeepLink(url)
        return ret
    }
}

