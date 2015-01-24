//
//  MainHomePage.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/12/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

class MainHomePage: UIViewController {
    let layers = [9:"ט׳",10:"י׳",11:"י״א", 12:"י״ב"]
    let numberToHebrewNumbers = [1:"ראשונה", 2:"שנייה", 3:"שלישית", 4:"רביעית", 5:"חמישית", 6:"שישית", 7:"שביעית", 8:"שמינית", 9:"תשיעית", 10:"עשירית", 11:"אחת-עשרה"]
    let numberToHebrewNumbersMale = [1:"ראשון", 2:"שני", 3:"שלישי", 4:"רביעי", 5:"חמישי", 6:"שישי", 7:"שבת"]
    let newLine = "\n"
    var final = NSMutableAttributedString()
    let fontHead: UIFont? = UIFont(name: "Alef-Bold", size: 24.0)
    let fontSubHead: UIFont? = UIFont(name: "Alef-Bold", size: 22.0)
    let fontBody: UIFont? = UIFont(name: "Alef-Regular", size: 20.0)

    @IBOutlet weak var theTextView: UITextView?

    func GetGreeting() -> String{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour

        var homeString = "שלום, "

        if 5 <= hour && hour < 12  {
            homeString = "בוקר טוב, "
        }

        if 12 <= hour && hour < 18 {
            homeString = "צהריים טובים, "
        }

        if 18 <= hour && hour < 22 {
            homeString = "ערב טוב, "
        }

        if 22 <= hour && hour < 0 {
            homeString = "לילה טוב, "
        }

        if 0 <= hour && hour < 5 {
            homeString = "לך לישון כבר, "
        }

        homeString = homeString + (NSUserDefaults.standardUserDefaults().valueForKey("studentName")? as String)
        homeString = homeString +  " מכיתה "
        homeString = homeString +  layers[NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue]!
        homeString = homeString +  " "
        homeString = homeString +  String(NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue)
        homeString = homeString +  ","
        homeString += " זהו הסיכום היומי שלך: \n \n"
        return homeString
    }

    func GetTodaysHours() -> [String]{
        //Compute date of today
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = NSDate(timeIntervalSinceNow: 0)
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar!.components(.WeekdayCalendarUnit, fromDate: todayDate)
        var weekDay: Int
        weekDay = myComponents.weekday

        //This checks if we should get tommorow's hours or today's hours
        if SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ")[SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ").count - 2] == numberToHebrewNumbersMale[weekDay]{

            return SchoolWebsiteDataManager.sharedInstance.GetHours(weekDay)

        } else {
            return SchoolWebsiteDataManager.sharedInstance.GetHours((weekDay == 7 ? 1 : weekDay + 1))
        }
    }

    func GetTodaysFormattedChanges(changesString: [String], hours: [String]) -> NSAttributedString {
        //Getting the changes
        var changes = NSMutableAttributedString(string: "")
        let attrBody = [NSFontAttributeName : fontBody! , NSForegroundColorAttributeName: UIColor.blackColor()]
        for (var i = 1; i < 12; i++) {
            if i - 1 < changesString.count {
                if (changesString[i - 1] != "-"){
                    //If we have a change, we show it
                    let attrChange = NSAttributedString(string: "•בשעה ה\(String(numberToHebrewNumbers[i]!)): " + changesString[i - 1] + "\n", attributes: [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.redColor()])
                    changes.appendAttributedString(attrChange)
                } else {
                    if hours[i-1] != "שעה חופשית!" && hours[i-1] != "אין לימודים בשבת!" {
                        //If we don't, we show the corresponding hour
                        var theHourWith = hours[i - 1].componentsSeparatedByString(" ")
                        theHourWith.insert("עם", atIndex: 1)
                        var display = join(" ", theHourWith) as String
                        changes.appendAttributedString(NSAttributedString(string: "•בשעה ה\(String(numberToHebrewNumbers[i]!)) יש \(display)\n", attributes: attrBody))
                    } else {
                        if hours[i-1] == "שעה חופשית!" {
                            let attrEmptyHour = NSAttributedString(string: "•בשעה ה\(String(numberToHebrewNumbers[i]!)) יש \(hours[i-1])\n", attributes: attrBody)
                            changes.appendAttributedString(attrEmptyHour)
                        } else {
                            let attrEmptyHour = NSAttributedString(string: "•בשעה ה\(String(numberToHebrewNumbers[i]!)) \(hours[i-1])\n", attributes: attrBody)
                            changes.appendAttributedString(attrEmptyHour)
                        }
                    }
                }
            } else {
                if hours[i-1] != "שעה חופשית!" && hours[i-1] != "אין לימודים בשבת!" {
                    var theHourWith = hours[i - 1].componentsSeparatedByString(" ")
                    //Check if it's special classes that don't let me put in the regular עם
                    //if hours[i-1] == "jbd"{}
                    theHourWith.insert("עם", atIndex: 1)
                    var display = join(" ", theHourWith) as String
                    changes.appendAttributedString(NSAttributedString(string: "•בשעה ה\(String(numberToHebrewNumbers[i]!)) יש \(display)\n", attributes: attrBody))
                } else {
                    if hours[i-1] == "שעה חופשית!" {
                        let attrEmptyHour = NSAttributedString(string: "•בשעה ה\(String(numberToHebrewNumbers[i]!)) יש \(hours[i-1])\n", attributes: attrBody)
                        changes.appendAttributedString(attrEmptyHour)
                    } else {
                        let attrEmptyHour = NSAttributedString(string: "•בשעה ה\(String(numberToHebrewNumbers[i]!)) \(hours[i-1])\n", attributes: attrBody)
                        changes.appendAttributedString(attrEmptyHour)
                    }
                }
            }
        }
        return changes
    }

    func SetHomeString() {

        var homeString = ""

        homeString += GetGreeting()

        let attrHead = [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()/*, NSStrokeWidthAttributeName : NSNumber(float: -3.0)Bold Header*/]
        let attributedTitle: NSAttributedString = NSAttributedString(string: homeString, attributes: attrHead)
        final.appendAttributedString(attributedTitle)

        //Show news
        let attrNews = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()/*, NSStrokeWidthAttributeName : NSNumber(float: -3.0)*/]
        let attributedNews: NSAttributedString = NSAttributedString(string: "החדשות החמות ביותר: \n", attributes: attrNews)
        final.appendAttributedString(attributedNews)

        let news = SchoolWebsiteDataManager.sharedInstance.GetNews(HTMLContent: false).componentsSeparatedByString(newLine)

        let attrBody = [NSFontAttributeName : fontBody! , NSForegroundColorAttributeName: UIColor.blackColor()]
        let attributedNewsBody = NSMutableAttributedString(string: "\(news[0]), \(news[2]), \(news[4])) \n \n", attributes: attrBody)
        final.appendAttributedString(attributedNewsBody)

        //Show changes
        let attrBegadol = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()/*, NSStrokeWidthAttributeName : NSNumber(float: -3.0)*/]
        let attributedBegadol: NSAttributedString = NSAttributedString(string: "בגדול, ככה היום שלך נראה: \n", attributes: attrBegadol)
        final.appendAttributedString(attributedBegadol)

        let changeFont: UIFont? = UIFont(name: "Alef-Regular", size: 20.0)

        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = NSDate(timeIntervalSinceNow: 10800)//Check if 3 hours from now is Saturday, since changes are in 9 pm
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar!.components(.WeekdayCalendarUnit, fromDate: todayDate)
        var weekDay: Int
        weekDay = myComponents.weekday

        let changes: NSAttributedString = (weekDay == 7 ? NSAttributedString(string: "אין לימודים בשבת!", attributes: attrBody) : GetTodaysFormattedChanges(SchoolWebsiteDataManager.sharedInstance.GetChanges(), hours: GetTodaysHours()))

        final.appendAttributedString(changes)

        //Show tests
        let attrTest = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()/*, NSStrokeWidthAttributeName : NSNumber(float: -3.0)*/]
        let attributedTestHead: NSAttributedString = NSAttributedString(string: "\n\nיש לך מבחנים בקרוב: \n", attributes: attrTest)
        final.appendAttributedString(attributedTestHead)

        let testFont: UIFont? = UIFont(name: "Alef-Regular", size: 20.0)
        let tests = SchoolWebsiteDataManager.sharedInstance.GetTests()
        var attrTests = NSMutableAttributedString(string: "\(tests[0]) \n\(tests[1]) \n\(tests[2]) \n", attributes: attrBody)
        final.appendAttributedString(attrTests)

        //Append the date of validity of system
        final.appendAttributedString(NSAttributedString(string: "\n" + SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges() + ", וגם מערכת השעות", attributes: [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.redColor()]))

        self.theTextView?.attributedText = final
        self.theTextView?.textAlignment = NSTextAlignment.Right

        let sharedDefaults = NSUserDefaults(suiteName: "group.LiorPollak.OhelShemExtensionSharingDefaults")

        let changesToTodayExt = changes.string + "\n" + SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges() + ", וגם מערכת השעות"

        sharedDefaults?.setValue(changesToTodayExt, forKey: "todayViewText")
        sharedDefaults?.synchronize()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.theTextView?.font = UIFont(name: "Alef-Regular", size: 18)
        SetHomeString()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addLeftMenuButton()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*let seen: Bool = NSUserDefaults.standardUserDefaults().boolForKey("seenTutorial")
        if seen {

        } else {*/
        if (UIApplication.sharedApplication().delegate! as AppDelegate).j == 0 {
            iRate.sharedInstance().daysUntilPrompt = 5
            iRate.sharedInstance().usesUntilPrompt = 15
            iRate.sharedInstance().verboseLogging = false
            (UIApplication.sharedApplication().delegate! as AppDelegate).j++
            self.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("FirstTimeHereViewControllerManager") as FirstTimeHereViewControllerManager, animated: true, { () -> Void in
                let i = 1
                let seenCoachingMarks = NSUserDefaults.standardUserDefaults().boolForKey("seenCoachingMarks")
                if seenCoachingMarks == false {
                //NSUserDefaults.standardUserDefaults().setBool(true, forKey: "seenCoachingMarks")
                //NSUserDefaults.standardUserDefaults().synchronize()
                // Setup coach marks
                let coachMarks = [
                [
                "rect": NSValue(CGRect: CGRectMake(0, 0, 45, 45)),//self.navigationItem.leftBarButtonItem!.customView!.frame),
                "caption": "תפריט"
                ]
                ]
                let coachMarksView = WSCoachMarksView(frame: self.view.frame, coachMarks: coachMarks)
                //self.view.addSubview(coachMarksView)
                //coachMarksView.start()
                }
            })
        }
        //}
    }
}