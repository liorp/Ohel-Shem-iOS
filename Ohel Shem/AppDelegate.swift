//
//  AppDelegate.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var j = 0

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Crashlytics.startWithAPIKey("9e4dce43dfba49a9386ebed039ab07d466d9596d")
        application.unregisterForRemoteNotifications()
        /*for family in UIFont.familyNames()
        {
            println(family)

            for name in UIFont.fontNamesForFamilyName((family as NSString))
            {
                println(name)
            }
        }*/

        // Override point for customization after application launch.


        if (application.applicationIconBadgeNumber > 0) {
            application.applicationIconBadgeNumber = 0
        }


        if application.respondsToSelector("registerUserNotificationSettings:") {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        } else {
            let localNotification = UILocalNotification()

            //let date = NSCalendar.currentCalendar().dateBySettingHour(21, minute: 03, second: 00, ofDate: NSDate(timeIntervalSinceNow: 0), options: NSCalendarOptions.MatchFirst)

            let now = NSDate(timeIntervalSinceNow: 0)
            let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            let components = calendar?.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit, fromDate: now)
            components?.setValue(21, forComponent: NSCalendarUnit.HourCalendarUnit)
            components?.setValue(3, forComponent: NSCalendarUnit.MinuteCalendarUnit)
            components?.setValue(0, forComponent: NSCalendarUnit.SecondCalendarUnit)

            localNotification.alertBody = "השינויים התעדכנו. רוצה לבדוק?"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.applicationIconBadgeNumber = 1
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.alertAction = "כן!"
            localNotification.repeatInterval = NSCalendarUnit.DayCalendarUnit
            localNotification.fireDate = calendar?.dateFromComponents(components!)

            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }

        let font : UIFont? = UIFont(name: "Alef-Bold", size: 22)

        UILabel.appearance().font = UIFont(name: "Alef-Regular", size: 18)
        UITextView.appearance().font = UIFont(name: "Alef-Regular", size: 18)
        UITextField.appearance().font = UIFont(name: "Alef-Regular", size: 16)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : font!]

        if let name: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("studentName") {

        } else {
            NSUserDefaults.standardUserDefaults().setValue("ליאור", forKey: "studentName")
        }
        if let classNum: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("classNum") {

        } else {
            NSUserDefaults.standardUserDefaults().setValue("4", forKey: "classNum")
        }
        if let layerNum: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("layerNum"){

        } else {
            NSUserDefaults.standardUserDefaults().setValue("11", forKey: "layerNum")
        }
        /* Siren code should go below window?.makeKeyAndVisible()

        // Siren is a singleton
        let siren = Siren.sharedInstance

        // Required: Your app's iTunes App Store ID
        siren.appID = "956866498"

        // Required on iOS 8: The controller to present the alert from (usually the UIWindow's rootViewController)
        siren.presentingViewController = window?.rootViewController

        // Optional: Defaults to .Option
        siren.alertType = SirenAlertType.Skip

        /*
        Replace .Immediately with .Daily or .Weekly to specify a maximum daily or weekly frequency for version
        checks.
        */
        siren.checkVersion(.Weekly)*/
        
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        let localNotification = UILocalNotification()

        let date = NSCalendar.currentCalendar().dateBySettingHour(21, minute: 03, second: 00, ofDate: NSDate(timeIntervalSinceNow: 0), options: NSCalendarOptions.MatchFirst)

        localNotification.alertBody = "השינויים התעדכנו. רוצה לבדוק?"
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.applicationIconBadgeNumber = 1
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertAction = "כן!"
        localNotification.repeatInterval = NSCalendarUnit.DayCalendarUnit
        localNotification.fireDate = date

        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
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
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

