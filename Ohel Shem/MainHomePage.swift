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
    let fontSmall: UIFont? = UIFont(name: "Alef-Regular", size: 16.0)

    let hebrewMonthToNumber = ["בינואר":1, "בפברואר":2, "במרץ":3, "באפריל":4, "במאי":5, "ביוני":6, "ביולי":7, "באוגוסט":8, "בספטמבר":9, "באוקטובר":10, "בנובמבר":11, "בדצמבר":12]
    var timer: NSTimer?
    var currentClassTimer: NSTimer?

    @IBOutlet var mainTextView: UITextView?
    @IBOutlet var progressOfCurrentClass: UIProgressView?
    @IBOutlet var currentClassLabel: UILabel?
    @IBOutlet var timeToEndCurrentClassLabel: UILabel?

    func GetGreeting() -> NSAttributedString{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Hour, fromDate: date)
        let hour = components.hour

        var greetingString = "שלום, "

        if 5 <= hour && hour < 12  {
            greetingString = "בוקר טוב, "
        }

        if 12 <= hour && hour < 18 {
            greetingString = "צהריים טובים, "
        }

        if 18 <= hour && hour < 22 {
            greetingString = "ערב טוב, "
        }

        if 22 <= hour && hour < 0 {
            greetingString = "לילה טוב, "
        }

        if 0 <= hour && hour < 5 {
            greetingString = "לך לישון כבר, "
        }

        greetingString = greetingString + (NSUserDefaults.standardUserDefaults().valueForKey("studentName") as! String)
        greetingString = greetingString +  " מכיתה "
        greetingString = greetingString +  layers[NSUserDefaults.standardUserDefaults().valueForKey("layerNum") as! Int]!
        greetingString = greetingString +  " "
        greetingString = greetingString +  String(NSUserDefaults.standardUserDefaults().valueForKey("classNum") as! Int)
        greetingString = greetingString +  ","
        greetingString += " זהו הסיכום היומי שלך: \n \n"



        return NSAttributedString(string: greetingString, attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
    }

    func GetTodaysHours() throws -> [String]{
        //Compute date of today
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = NSDate(timeIntervalSinceNow: 0)
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let myComponents = myCalendar!.components(NSCalendarUnit.Weekday, fromDate: todayDate)
        var weekDay: Int
        weekDay = myComponents.weekday

        //This checks if we should get tommorow's hours or today's hours
        let day = try SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ")
        if day[day.count - 2] == numberToHebrewNumbersMale[weekDay]{
            let hours = try SchoolWebsiteDataManager.sharedInstance.GetHours(weekDay)
            return hours

        } else {
            let hours = try SchoolWebsiteDataManager.sharedInstance.GetHours((weekDay == 7 ? 1 : weekDay + 1))
            return hours
        }
    }

    func GetHourNumbered(number: Int) -> String {
        do {

            if (number == -1) {
                return "הפסקה!"
            }
            if (number == -2) {
                return "נגמר ביה״ס!"
            }
            if (number == -3) {
                return "אין לימודים בשבת!"
            }

            //Checking for Sabbath

            let todayDate = NSDate(timeIntervalSinceNow: 10800)//Check if 3 hours from now is Saturday, since changes are in 9 pm
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            let myComponents = myCalendar!.components(NSCalendarUnit.Weekday, fromDate: todayDate)
            var weekDay: Int
            weekDay = myComponents.weekday

            var stillSabbath = true
            if try SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ")[SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ").count - 2] != numberToHebrewNumbersMale[7] {
                stillSabbath = false
            }
            if weekDay == 7 || stillSabbath {
                return "אין לימודים בשבת!"
            }


            let hours = try self.GetTodaysHours()
            let changes = try SchoolWebsiteDataManager.sharedInstance.GetChanges()
            if let noChanges = changes.first where noChanges == "אין שינויים" {
                return "השיעור הנוכחי: " + hours[number-1]
            } else {
                if changes[number-1] != "-" {
                    return changes[number-1]
                } else {
                    return hours[number-1]
                }
            }
        } catch {
            print(error)
            return "התרחשה שגיאה"
        }
    }

    func GetTodaysFormattedChanges() throws -> NSAttributedString {
        let attrBody = [NSFontAttributeName : fontBody! , NSForegroundColorAttributeName: UIColor.blackColor()]
        let attrWith = [NSFontAttributeName : fontSmall! , NSForegroundColorAttributeName: UIColor.blackColor()]

        //Getting the changes

        var changesString = try SchoolWebsiteDataManager.sharedInstance.GetChanges()
        //First, check for no changes at all
        if let noChanges = changesString.first where noChanges == "אין שינויים" {
            changesString = []
        }

        //Now begins the fun
        //Checking for Sabbath

        let todayDate = NSDate(timeIntervalSinceNow: 10800)//Check if 3 hours from now is Saturday, since changes are in 9 pm
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let myComponents = myCalendar!.components(NSCalendarUnit.Weekday, fromDate: todayDate)
        var weekDay: Int
        weekDay = myComponents.weekday

        var stillSabbath = true
        if try SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ")[SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ").count - 2] != numberToHebrewNumbersMale[7] {
            stillSabbath = false
        }
        let hours = try GetTodaysHours()
        if weekDay == 7 || stillSabbath {
            return NSAttributedString(string: "אין לימודים בשבת!\n", attributes: attrBody)
        } else {
            let changes = NSMutableAttributedString()

            func AppendRegularHour(i : Int) -> NSAttributedString {
                let appendedString = NSMutableAttributedString()
                if hours[i-1] != "שעה חופשית!" && hours[i-1] != "אין לימודים בשבת!" {
                    //If we don't, we show the corresponding hour
                    var theHourWith = hours[i - 1].componentsSeparatedByString(" ")
                    theHourWith.insert("עם", atIndex: 1)
                    let display = theHourWith.joinWithSeparator(" ") as String
                    let theHourName = display.componentsSeparatedByString(" ").first!
                    var theHourWith1 = display.componentsSeparatedByString(" ")
                    theHourWith1.removeFirst()
                    let theHourWith2 = theHourWith1.joinWithSeparator(" ")
                    appendedString.appendAttributedString(NSAttributedString(string: "◉ בשעה ה\(String(numberToHebrewNumbers[i]!)) יש \(theHourName)", attributes: attrBody))
                    appendedString.appendAttributedString(NSAttributedString(string: " \(theHourWith2)\n", attributes: attrWith))
                } else {
                    if hours[i-1] == "שעה חופשית!" {
                        let attrEmptyHour = NSAttributedString(string: "◉ בשעה ה\(String(numberToHebrewNumbers[i]!)) יש \(hours[i-1])\n", attributes: attrBody)
                        appendedString.appendAttributedString(attrEmptyHour)
                    } else {
                        let attrEmptyHour = NSAttributedString(string: "◉ בשעה ה\(String(numberToHebrewNumbers[i]!)) \(hours[i-1])\n", attributes: attrBody)
                        appendedString.appendAttributedString(attrEmptyHour)
                    }
                }
                return appendedString
            }

            for (var i = 1; i < 12; i++) {
                if i - 1 < changesString.count {
                    if (changesString[i - 1] != "-"){
                        //If we have a change, we show it
                        let attrChange = NSAttributedString(string: "◉ בשעה ה\(String(numberToHebrewNumbers[i]!)): " + changesString[i - 1] + "\n", attributes: [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.redColor()])
                        changes.appendAttributedString(attrChange)
                    } else {
                        changes.appendAttributedString(AppendRegularHour(i))
                    }
                } else {
                    changes.appendAttributedString(AppendRegularHour(i))
                }
            }
            return changes
        }
    }

    func GetTop(numberOfTests num : Int) -> NSAttributedString{
        var returnString = NSMutableAttributedString(string: "")
        let attrBody = [NSFontAttributeName : fontBody! , NSForegroundColorAttributeName: UIColor.blackColor()]
        //let testFont: UIFont? = UIFont(name: "Alef-Regular", size: 20.0)
        let tests = SchoolWebsiteDataManager.sharedInstance.GetTests()
        // FIX: This should be updated to match the latest version of test system
        /*for (var i = 0, j = 0; i < tests.count && j < num; i++) {
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
        }*/
        returnString = NSMutableAttributedString(string: "\(tests[0])\n", attributes: attrBody)
        return returnString
    }

    func GetChangesHours() throws -> NSAttributedString {
        //Append the date of validity of system
        let dayOfChanges = try SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges()

        let today = NSDate(timeIntervalSinceNow: 0)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let nowDate = dateFormatter.stringFromDate(today)
        dateFormatter.dateFormat = "HH:mm:ss"
        let nowHour = dateFormatter.stringFromDate(today)

        let finalString = NSAttributedString(string: dayOfChanges + ", וגם מערכת השעות" + "\nנלקח בתאריך \(nowDate), בשעה \(nowHour)", attributes: [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.redColor()])
        return finalString
    }

    func GetNews() throws -> NSAttributedString {
        let attrNews = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()]
        let attributedNews: NSAttributedString = NSAttributedString(string: "החדשות החמות ביותר: \n", attributes: attrNews)
        //final.appendAttributedString(attributedNews)

        let news = try SchoolWebsiteDataManager.sharedInstance.GetNews(HTMLContent: false).componentsSeparatedByString(newLine)

        let attrBody = [NSFontAttributeName : fontBody! , NSForegroundColorAttributeName: UIColor.blackColor()]
        let attributedNewsBody = NSMutableAttributedString(string: "\(news[0]), \(news[2]), \(news[4]) \n \n", attributes: attrBody)
        //final.appendAttributedString(attributedNewsBody)
        let mutab = NSMutableAttributedString(attributedString: attributedNews)
        mutab.appendAttributedString(attributedNewsBody)

        return mutab
    }

    func BeginInit(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "animateLoading:", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)

        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            do {
                let greetingText = self.GetGreeting()
                let newsText = try self.GetNews()
                let begadolText = try self.GetTodaysFormattedChanges()
                let dateText = try self.GetChangesHours()

                let mutableAttrString = NSMutableAttributedString(attributedString: greetingText)
                mutableAttrString.appendAttributedString(newsText)
                mutableAttrString.appendAttributedString(begadolText)
                mutableAttrString.appendAttributedString(NSAttributedString(string: "\n"))
                mutableAttrString.appendAttributedString(dateText)


                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    self.timer?.invalidate()

                    self.mainTextView?.attributedText = mutableAttrString
                    self.mainTextView?.textAlignment = NSTextAlignment.Right

                    self.currentClassTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "UpdateProgressView:", userInfo: nil, repeats: true)
                    NSRunLoop.currentRunLoop().addTimer(self.currentClassTimer!, forMode: NSRunLoopCommonModes)

                    self.currentClassLabel?.text = self.GetHourNumbered(self.GetNumberOfCurrentClass())
                    //self.addCornersToView(self.mainTextView!)

                    print("go")
                    UIView.animateWithDuration(0.5, delay: 0.5, options: [UIViewAnimationOptions.CurveEaseOut], animations: { () -> Void in
                        self.progressOfCurrentClass?.alpha = 1
                        }) { (completed) -> Void in
                            UIView.animateWithDuration(0.5, delay: 0, options: [UIViewAnimationOptions.CurveEaseOut], animations: { () -> Void in
                                self.currentClassLabel?.alpha = 1
                                }) { (completed) -> Void in
                                    UIView.animateWithDuration(0.5, delay: 0, options: [UIViewAnimationOptions.CurveEaseOut], animations: { () -> Void in
                                        self.timeToEndCurrentClassLabel?.alpha = 1
                                        }) { (completed) -> Void in
                                    }
                            }
                    }
                }
            } catch {
                print(error)
                let textToDisplay = "קרתה שגיאה בתהליך ההתחברות לשרת"
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    self.timer?.invalidate()
                    self.mainTextView?.text = textToDisplay
                }
            }
        }
    }

    func UpdateProgressView(timer: NSTimer) {
        let frac = GetFractionOfTimeLeftForCurrentClass()
        if frac >= 0 {
            self.progressOfCurrentClass?.progress = frac
            self.timeToEndCurrentClassLabel?.text = "זמן לסיום: \(frac*45) דקות"
        } else {
            self.progressOfCurrentClass?.progress = 1
            self.timeToEndCurrentClassLabel?.text = ""
        }
    }

    func GetFractionOfTimeLeftForCurrentClass() -> Float {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Hour, fromDate: date)
        let hour = components.hour
        let minute = Float(components.minute)
        //let second = components.second

        if components.weekday == 7 {
            return -3
        }

        //First class
        if hour == 8 && 0 <= minute && minute <= 45 {
            return minute/45
        }

        //Second class
        if (hour == 8 && 50 <= minute) || (hour == 9 && minute <= 35) {
            if (hour == 8 && 50 <= minute) {
                return (minute-50)/45
            }
            if (hour == 9 && minute <= 35) {
                return (minute+10)/45
            }
        }

        //Third class
        if (hour == 9 && 50 <= minute) || (hour == 10 && minute <= 35) {
            if (hour == 9 && 50 <= minute) {
                return (minute-50)/45
            }
            if (hour == 10 && minute <= 35) {
                return (minute+10)/45
            }
        }

        //Fourth class
        if (hour == 10 && 40 <= minute) || (hour == 11 && minute <= 25) {
            if (hour == 10 && 40 <= minute) {
                return (minute-40)/45
            }
            if (hour == 11 && minute <= 25) {
                return (minute+20)/45
            }
        }

        //Fifth class
        if (hour == 11 && 45 <= minute) || (hour == 12 && minute <= 30) {
            if (hour == 11 && 45 <= minute) {
                return (minute-45)/45
            }
            if (hour == 12 && minute <= 30) {
                return (minute+15)/45
            }
        }

        //Sixth class
        if (hour == 12 && 35 <= minute) || (hour == 13 && minute <= 20) {
            if (hour == 12 && 35 <= minute) {
                return (minute-35)/45
            }
            if (hour == 13 && minute <= 20) {
                return (minute+25)/45
            }
        }

        //Seventh class
        if (hour == 13 && 30 <= minute) || (hour == 14 && minute <= 15) {
            if (hour == 13 && 30 <= minute) {
                return (minute-30)/45
            }
            if (hour == 14 && minute <= 15) {
                return (minute+30)/45
            }
        }

        //Eighth class
        if (hour == 14 && 20 <= minute) || (hour == 15 && minute <= 05) {
            if (hour == 14 && 20 <= minute) {
                return (minute-20)/45
            }
            if (hour == 15 && minute <= 05) {
                return (minute+40)/45
            }
        }

        //Nineth class
        if (hour == 15 && 10 <= minute) || (hour == 15 && minute <= 55) {
            return (minute-10)/45
        }

        //Tenth class
        if (hour == 16 && 00 <= minute) || (hour == 16 && minute <= 45) {
            return minute/45
        }

        //Eleventh class
        if (hour == 16 && 50 <= minute) || (hour == 17 && minute <= 35) {
            if (hour == 16 && 50 <= minute) {
                return (minute-50)/45
            }
            if (hour == 17 && minute <= 35) {
                return (minute+10)/45
            }
        }

        if (hour == 17 && minute > 35) || (hour > 17) || (hour < 8) {
            return -2
        }
        
        return -1
    }

    /**
    Uses current time to determine the current class

    - returns: The current class number, or -1 if it is break, or -2 if it is not school, or -3 if it's Sabbath
    */
    func GetNumberOfCurrentClass() -> Int {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Hour, fromDate: date)
        let hour = components.hour
        let minute = components.minute
        //let second = components.second

        if components.weekday == 7 {
            return -3
        }

        //First class
        if hour == 8 && 0 <= minute && minute <= 45 {
            return 1
        }

        //Second class
        if (hour == 8 && 50 <= minute) || (hour == 9 && minute <= 35) {
            return 2
        }

        //Third class
        if (hour == 9 && 50 <= minute) || (hour == 10 && minute <= 35) {
            return 3
        }

        //Fourth class
        if (hour == 10 && 40 <= minute) || (hour == 11 && minute <= 25) {
            return 4
        }

        //Fifth class
        if (hour == 11 && 45 <= minute) || (hour == 12 && minute <= 30) {
            return 5
        }

        //Sixth class
        if (hour == 12 && 35 <= minute) || (hour == 13 && minute <= 20) {
            return 6
        }

        //Seventh class
        if (hour == 13 && 30 <= minute) || (hour == 14 && minute <= 15) {
            return 7
        }

        //Eighth class
        if (hour == 14 && 20 <= minute) || (hour == 15 && minute <= 05) {
            return 8
        }

        //Nineth class
        if (hour == 15 && 10 <= minute) || (hour == 15 && minute <= 55) {
            return 9
        }

        //Tenth class
        if (hour == 16 && 00 <= minute) || (hour == 16 && minute <= 45) {
            return 10
        }

        //Eleventh class
        if (hour == 16 && 50 <= minute) || (hour == 17 && minute <= 35) {
            return 11
        }

        if (hour == 17 && minute > 35) || (hour > 17) || (hour < 8) {
            return -2
        }

        return -1
    }

    func fixTextView(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
    }

    func addCornersToView(view: UIView) {
        view.layer.cornerRadius = 10.0
        view.layer.borderColor = UIColor.grayColor().CGColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.theTextView?.font = UIFont(name: "Alef-Regular", size: 18)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addLeftMenuButton()
        self.mainTextView?.attributedText = NSAttributedString(string: "מעדכן", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
        self.mainTextView?.textAlignment = NSTextAlignment.Center

        self.mainTextView?.alpha = 0
        self.progressOfCurrentClass?.alpha = 0
        self.currentClassLabel?.alpha = 0
        self.timeToEndCurrentClassLabel?.alpha = 0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "BeginInit:", name: "finishedTutorial", object: nil)

        UpdateProgressView(NSTimer())

        self.mainTextView?.contentOffset = CGPointMake(0, -self.navigationController!.navigationBar.frame.height)
        let seen: Bool = NSUserDefaults.standardUserDefaults().boolForKey("seenTutorial")
        if seen {
            self.BeginInit(NSNotification(name: "Dummy notification", object: nil))
        } else {
            iRate.sharedInstance().daysUntilPrompt = 5
            iRate.sharedInstance().usesUntilPrompt = 15
            iRate.sharedInstance().verboseLogging = false
            self.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("FirstTimeHereViewControllerManager") as! FirstTimeHereViewControllerManager, animated: true, completion: { () -> Void in
                let seenCoachingMarks = NSUserDefaults.standardUserDefaults().boolForKey("seenCoachingMarks")
                if seenCoachingMarks == false {
                    //NSUserDefaults.standardUserDefaults().setBool(true, forKey: "seenCoachingMarks")
                    //NSUserDefaults.standardUserDefaults().synchronize()
                    // Setup coach marks
                    /*let coachMarks = [
                    [
                    "rect": NSValue(CGRect: CGRectMake(0, 0, 45, 45)),//self.navigationItem.leftBarButtonItem!.customView!.frame),
                    "caption": "תפריט"
                    ]
                    ]*/
                    //let coachMarksView = WSCoachMarksView(frame: self.view.frame, coachMarks: coachMarks)
                    //self.view.addSubview(coachMarksView)
                    //coachMarksView.start()
                }
            })
        }
    }

    func animateLoading(timer: NSTimer) {
        /*var animation = CATransition()
        animation.duration = 0.5
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromRight
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.theTextView?.layer.addAnimation(animation, forKey: "changeTextTransition")*/
        /*var animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")

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
        self.theTextView?.layer.addAnimation(animation, forKey: "loading.animation.key")*/
        if (self.mainTextView?.alpha == 0) {
            UIView.animateWithDuration(0.5, delay: 0, options: [UIViewAnimationOptions.CurveEaseOut], animations: { () -> Void in
                self.mainTextView?.alpha = 1
                }) { (completed) -> Void in

            }
        }
        if (self.mainTextView?.text == "מעדכן...") {
            self.mainTextView?.attributedText = NSAttributedString(string: "מעדכן", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
            self.mainTextView?.textAlignment = NSTextAlignment.Center
        } else if (self.mainTextView?.text == "מעדכן..") {
            self.mainTextView?.attributedText = NSAttributedString(string: "מעדכן...", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
            self.mainTextView?.textAlignment = NSTextAlignment.Center
        } else if (self.mainTextView?.text == "מעדכן."){
            self.mainTextView?.attributedText = NSAttributedString(string: "מעדכן..", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
            self.mainTextView?.textAlignment = NSTextAlignment.Center
        } else if (self.mainTextView?.text == "מעדכן"){
            self.mainTextView?.attributedText = NSAttributedString(string: "מעדכן.", attributes: [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()])
            self.mainTextView?.textAlignment = NSTextAlignment.Center
        }
    }

    //func GetHomeString() throws -> NSAttributedString {

    /*var homeString = ""

    homeString += GetGreeting()

    let attrHead = [NSFontAttributeName : fontHead!, NSForegroundColorAttributeName: UIColor.blackColor()/*, NSStrokeWidthAttributeName : NSNumber(float: -3.0)Bold Header*/]
    let attributedTitle: NSAttributedString = NSAttributedString(string: homeString, attributes: attrHead)
    final.appendAttributedString(attributedTitle)*/

    //Show news
    /*let attrNews = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()]
    let attributedNews: NSAttributedString = NSAttributedString(string: "החדשות החמות ביותר: \n", attributes: attrNews)
    final.appendAttributedString(attributedNews)

    let news = try SchoolWebsiteDataManager.sharedInstance.GetNews(HTMLContent: false).componentsSeparatedByString(newLine)

    let attrBody = [NSFontAttributeName : fontBody! , NSForegroundColorAttributeName: UIColor.blackColor()]
    let attributedNewsBody = NSMutableAttributedString(string: "\(news[0]), \(news[2]), \(news[4]) \n \n", attributes: attrBody)
    final.appendAttributedString(attributedNewsBody)*/

    //Show changes
    /*let attrBegadol = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()]
    let attributedBegadol: NSAttributedString = NSAttributedString(string: "בגדול, ככה היום שלך נראה: \n", attributes: attrBegadol)
    final.appendAttributedString(attributedBegadol)
    */

    //let changeFont: UIFont? = UIFont(name: "Alef-Regular", size: 20.0)
    /*
    let todayDate = NSDate(timeIntervalSinceNow: 10800)//Check if 3 hours from now is Saturday, since changes are in 9 pm
    let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    let myComponents = myCalendar!.components(NSCalendarUnit.Weekday, fromDate: todayDate)
    var weekDay: Int
    weekDay = myComponents.weekday

    var stillSabbath = true

    if try SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ")[SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges().componentsSeparatedByString(" ").count - 2] != numberToHebrewNumbersMale[7] {
    stillSabbath = false
    }
    let hours = try GetTodaysHours()
    let changes: NSAttributedString = ((weekDay == 7 || stillSabbath) ? NSAttributedString(string: "אין לימודים בשבת!\n", attributes: attrBody) : GetTodaysFormattedChanges(try SchoolWebsiteDataManager.sharedInstance.GetChanges(), hours: hours))

    final.appendAttributedString(changes)
    */


    //Show tests
    //let attrTest = [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.blackColor()/*, NSStrokeWidthAttributeName : NSNumber(float: -3.0)*/]
    //let attributedTestHead: NSAttributedString = NSAttributedString(string: "\nיש לך מבחנים בקרוב: \n", attributes: attrTest)
    //final.appendAttributedString(attributedTestHead)

    //let testFont: UIFont? = UIFont(name: "Alef-Regular", size: 20.0)
    //let tests = SchoolWebsiteDataManager.sharedInstance.GetTests()
    //final.appendAttributedString(GetTop(numberOfTests: 3))

    //Append the date of validity of system
    /*let dayOfChanges = try SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges()
    final.appendAttributedString(NSAttributedString(string: "\n" + dayOfChanges + ", וגם מערכת השעות", attributes: [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.redColor()]))

    let today = NSDate(timeIntervalSinceNow: 0)
    //let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    //let components = calendar!.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: today)

    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    let nowDate = dateFormatter.stringFromDate(today)
    dateFormatter.dateFormat = "HH:mm:ss"
    let nowHour = dateFormatter.stringFromDate(today)
    let dateString = "\nנלקח בתאריך \(nowDate), בשעה \(nowHour)"
    
    final.appendAttributedString(NSAttributedString(string: dateString, attributes: [NSFontAttributeName : fontSubHead! , NSForegroundColorAttributeName: UIColor.redColor()]))
    
    let sharedDefaults = NSUserDefaults(suiteName: "group.LiorPollak.OhelShemExtensionSharingDefaults")
    
    let changesToTodayExt = /*changes.string +*/ " " + dayOfChanges + ", וגם מערכת השעות\n\(dateString)"
    
    sharedDefaults?.setValue(changesToTodayExt, forKey: "todayViewText")
    sharedDefaults?.synchronize()*/
    
    //return final
    //}
}