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
    let hebrewMonthToNumber = ["בינואר":1, "בפברואר":2, "במרץ":3, "באפריל":4, "במאי":5, "ביוני":6, "ביולי":7, "באוגוסט":8, "בספטמבר":9, "באוקטובר":10, "בנובמבר":11, "בדצמבר":12]
    var timer: NSTimer?

    @IBOutlet weak var theTextView: UITextView?

    func GetGreeting() -> String{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour, fromDate: date)
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
        func AppendRegularHour(i : Int) {
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
        for (var i = 1; i < 12; i++) {
            if i - 1 < changesString.count {
                if (changesString[i - 1] != "-"){
                    //If we have a change, we show it
                    let attrChange = NSAttributedString(string: "•בשעה ה\(String(numberToHebrewNumbers[i]!)): " + changesString[i - 1] + "\n", attributes: [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.redColor()])
                    changes.appendAttributedString(attrChange)
                } else {
                    AppendRegularHour(i)
                }
            } else {
                AppendRegularHour(i)
            }
        }
        return changes
    }

    func GetTop(numberOfTests num : Int) -> NSAttributedString{
        var returnString = NSMutableAttributedString(string: "")
        let attrBody = [NSFontAttributeName : fontBody! , NSForegroundColorAttributeName: UIColor.blackColor()]
        let testFont: UIFont? = UIFont(name: "Alef-Regular", size: 20.0)
        let tests = SchoolWebsiteDataManager.sharedInstance.GetTests()

        for (var i = 0, j = 0; i < tests.count && j < num; i++) {
            let currentTest = tests[i].componentsSeparatedByString(" ")
            var dateComponenta = NSDateComponents()
            var k = (currentTest[1] != "במועד" ? 0 : 1)

            let year = currentTest[6 + k] as NSString
            let month = self.hebrewMonthToNumber[(currentTest[5 + k].stripCharactersInSet([","]) as NSString)]
            let day = currentTest[4 + k].stripCharactersInSet(["ה", "-"]) as NSString
            dateComponenta.day = day.integerValue
            dateComponenta.month = month!
            dateComponenta.year = year.integerValue

            let dateOfReminder = NSCalendar.currentCalendar().dateFromComponents(dateComponenta)
            if (dateOfReminder?.compare(NSDate(timeIntervalSinceNow: 0)) == NSComparisonResult.OrderedDescending) {
                returnString.appendAttributedString(NSAttributedString(string: "\(tests[i])\n", attributes: attrBody))
                j++
            }
        }
        return returnString
    }

    func GetHomeString() -> NSAttributedString {

        var homeString = ""

        homeString += GetGreeting()

        let attrHead = [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()/*, NSStrokeWidthAttributeName : NSNumber(float: -3.0)Bold Header*/]
        let attributedTitle: NSAttributedString = NSAttributedString(string: homeString, attributes: attrHead)
        final.appendAttributedString(attributedTitle)

        //Show news
        let attrNews = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()]
        let attributedNews: NSAttributedString = NSAttributedString(string: "החדשות החמות ביותר: \n", attributes: attrNews)
        final.appendAttributedString(attributedNews)

        let news = SchoolWebsiteDataManager.sharedInstance.GetNews(HTMLContent: false).componentsSeparatedByString(newLine)

        let attrBody = [NSFontAttributeName : fontBody! , NSForegroundColorAttributeName: UIColor.blackColor()]
        let attributedNewsBody = NSMutableAttributedString(string: "\(news[0]), \(news[2]), \(news[4]) \n \n", attributes: attrBody)
        final.appendAttributedString(attributedNewsBody)

        //Show changes
        let attrBegadol = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()]
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

        var stillSabbath = true

        if SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ")[SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ").count - 2] != numberToHebrewNumbersMale[7] {
            stillSabbath = false
        }

        let changes: NSAttributedString = ((weekDay == 7 || stillSabbath) ? NSAttributedString(string: "אין לימודים בשבת!\n", attributes: attrBody) : GetTodaysFormattedChanges(SchoolWebsiteDataManager.sharedInstance.GetChanges(), hours: GetTodaysHours()))

        final.appendAttributedString(changes)

        //Show tests
        let attrTest = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()/*, NSStrokeWidthAttributeName : NSNumber(float: -3.0)*/]
        let attributedTestHead: NSAttributedString = NSAttributedString(string: "\nיש לך מבחנים בקרוב: \n", attributes: attrTest)
        final.appendAttributedString(attributedTestHead)

        let testFont: UIFont? = UIFont(name: "Alef-Regular", size: 20.0)
        let tests = SchoolWebsiteDataManager.sharedInstance.GetTests()
        //var attrTests = NSMutableAttributedString(string: "\(tests[0]) \n\(tests[1]) \n\(tests[2]) \n", attributes: attrBody)
        final.appendAttributedString(GetTop(numberOfTests: 3))

        //Append the date of validity of system
        final.appendAttributedString(NSAttributedString(string: "\n" + SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges() + ", וגם מערכת השעות", attributes: [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.redColor()]))

        let sharedDefaults = NSUserDefaults(suiteName: "group.LiorPollak.OhelShemExtensionSharingDefaults")

        let changesToTodayExt = changes.string + " " + SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges() + ", וגם מערכת השעות"

        sharedDefaults?.setValue(changesToTodayExt, forKey: "todayViewText")
        sharedDefaults?.synchronize()

        return final
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.theTextView?.font = UIFont(name: "Alef-Regular", size: 18)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addLeftMenuButton()
        self.theTextView?.attributedText = NSAttributedString(string: "מעדכן", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
        self.theTextView?.textAlignment = NSTextAlignment.Center
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        //timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "animateLoading:", userInfo: nil, repeats: true)
        self.animateLoading(NSTimer())
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            let textToDisplay = self.GetHomeString()
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                //self.timer?.invalidate()
                self.theTextView?.layer.removeAllAnimations()
                self.theTextView?.attributedText = textToDisplay
                self.theTextView?.textAlignment = NSTextAlignment.Right
            }
        }
/*
        //self.theTextView?.contentOffset = CGPointMake(0, -self.navigationController!.navigationBar.frame.height)
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
*/
    }

    func animateLoading(timer: NSTimer) {
        /*var animation = CATransition()
        animation.duration = 0.5
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromRight
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.theTextView?.layer.addAnimation(animation, forKey: "changeTextTransition")*/
        var animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")

        let times = [0.0, 0.25, 0.45, 0.90, 1.0]
        let angles = [0, (-M_PI * 20.0/180.0), (-M_PI * 20.0/180.0), (M_PI * 2.0), (M_PI * 2.0)]
        let functions = [CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn), CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn), CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut), CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)]
        animation.keyTimes = times
        animation.values = angles
        animation.timingFunctions = functions
        animation.duration = 1.7
        animation.repeatCount = Float.infinity
        let oldFrame = self.theTextView?.frame
        self.theTextView?.layer.anchorPoint = CGPointMake(0.5, 0)
        self.theTextView?.frame = oldFrame!
        self.theTextView?.layer.addAnimation(animation, forKey: "loading.animation.key")

        /*if (self.theTextView?.text == "מעדכן...") {
            self.theTextView?.attributedText = NSAttributedString(string: "מעדכן", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
            self.theTextView?.textAlignment = NSTextAlignment.Center
        } else if (self.theTextView?.text == "מעדכן..") {
            self.theTextView?.attributedText = NSAttributedString(string: "מעדכן...", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
            self.theTextView?.textAlignment = NSTextAlignment.Center
        } else if (self.theTextView?.text == "מעדכן."){
            self.theTextView?.attributedText = NSAttributedString(string: "מעדכן..", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
            self.theTextView?.textAlignment = NSTextAlignment.Center
        } else if (self.theTextView?.text == "מעדכן"){
            self.theTextView?.attributedText = NSAttributedString(string: "מעדכן.", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
            self.theTextView?.textAlignment = NSTextAlignment.Center
        }*/
    }
}