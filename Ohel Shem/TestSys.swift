//
//  ChangesSys.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit
import EventKit

/*extension String {
    func stripCharactersInSet(chars: [Character]) -> String {
        return String(filter(self) {find(chars, $0) == nil})
    }
}*/

class TestSys: UITableViewController {

    @IBOutlet weak var refresherControl: UIRefreshControl?

    var testsArray = [[String]]()
    var isRefreshing = false

    let hebrewMonthToNumber = ["בינואר":1, "בפברואר":2, "במרץ":3, "באפריל":4, "במאי":5, "ביוני":6, "ביולי":7, "באוגוסט":8, "בספטמבר":9, "באוקטובר":10, "בנובמבר":11, "בדצמבר":12]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.addLeftMenuButton()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        /*self.tableView.tableFooterView = UIView(frame: CGRectZero)
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.backgroundView = blurEffectView

        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)*/

        isRefreshing = true

        self.tableView.rowHeight = 60

        self.tableView.estimatedRowHeight = 60
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        isRefreshing = true
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            do {
                self.testsArray = try SchoolWebsiteDataManager.sharedInstance.GetTests()
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    //let i = 0
                    self.isRefreshing = false
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                    //self.theTextView?.attributedText = textToDisplay
                    //self.theTextView?.textAlignment = NSTextAlignment.Right
                }
            } catch {
                print(error)
            }
        }
    }

    @IBAction func willRefresh(sender: UIRefreshControl){
        refreshControl!.attributedTitle! = NSAttributedString(string: "בודק מבחנים")
        defer{
            refreshControl!.endRefreshing()
        }
        do {
            testsArray = try SchoolWebsiteDataManager.sharedInstance.GetTests()
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)

            //formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
            //NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSinceNow: 0), dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            let lastUpdated = "התעדכן לאחרונה ב: " + NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSinceNow: 0), dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)//formatter.stringFromDate(NSDate(timeIntervalSinceNow: 0))
            refreshControl!.attributedTitle! = NSAttributedString(string: lastUpdated)
        }
        catch {
            print(error)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = self.tableView.cellForRowAtIndexPath(indexPath)
        //let titleSpaceSeperated = ((selectedCell! as! CustomTestCell).titleText!.text! as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        //let subtitleSpaceSeperated = ((selectedCell! as! CustomTestCell).subtitleText!.text! as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

            var saveAlert: UIAlertController

            //If it's a moed b we display moed b
            saveAlert = UIAlertController(title: "רוצה שאזכיר לך לפני?", message: ("על המבחן ב" + (selectedCell! as! CustomTestCell).titleText!.text!), preferredStyle: UIAlertControllerStyle.Alert)

            let cancelAction = UIAlertAction(title: "לא", style: .Cancel) { (action) in
                selectedCell!.setSelected(false, animated: false)
            }
            saveAlert.addAction(cancelAction)

            let OKAction = UIAlertAction(title: "כן", style: .Default) { (action) in
                let daysTextField = saveAlert.textFields![0] 
                let num = Int(daysTextField.text!)
                selectedCell?.setSelected(false, animated: false)
                do {
                    try self.haveAReminder(date: (selectedCell! as! CustomTestCell).subtitleText!.text! , subject: (selectedCell! as! CustomTestCell).titleText!.text! , numberOfDaysBefore: num!)
                } catch {
                    print(error)
                }
            }

            OKAction.enabled = false

            saveAlert.addAction(OKAction)

            saveAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "כמה ימים לפני?"

                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                    OKAction.enabled = (textField.text != "" && Int(textField.text!) != nil)
                })
            }
            
            self.presentViewController(saveAlert, animated: true) {
                // ...
            }
    }

    func haveAReminder(date date: String, subject: String, numberOfDaysBefore days: Int) throws {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let testDate = dateFormatter.dateFromString(date)

        let dateComponenta = NSDateComponents()

        dateComponenta.day = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: testDate!) - days
        dateComponenta.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: testDate!)
        dateComponenta.year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: testDate!)

        //let dateOfReminder = NSCalendar.currentCalendar().dateFromComponents(dateComponenta)

        let eventStore : EKEventStore = EKEventStore()
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        eventStore.requestAccessToEntityType(EKEntityType.Reminder, completion: {
            granted, error in
            if (granted) && (error == nil) {

                let reminder = EKReminder(eventStore: eventStore)
                let random = arc4random_uniform(6)
                let randomSmiley: String
                switch (random) {
                case 1:
                    randomSmiley = "😅"
                    break;
                case 2:
                    randomSmiley = "😕"
                    break;
                case 3:
                    randomSmiley = "😵"
                    break;
                case 4:
                    randomSmiley = "💩"
                    break;
                case 5:
                    randomSmiley = "😢"
                    break;
                default:
                    randomSmiley = "💀"
                    break;
                }

                reminder.title = "מבחן ב" + subject + " " + randomSmiley
                reminder.notes = "צריך ללמוד כדי להצליח!"
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                reminder.startDateComponents = dateComponenta
                reminder.dueDateComponents = dateComponenta

                do {
                    try eventStore.saveReminder(reminder, commit: true)
                }
                catch{
                    let notSavedAlert = UIAlertController(title: "שגיאה", message: "לא יכולנו ליצור תזכורת עבור המבחן", preferredStyle: UIAlertControllerStyle.Alert)

                    let OKAction = UIAlertAction(title: "אוף", style: .Default) { (action) in
                    }
                    notSavedAlert.addAction(OKAction)

                    self.presentViewController(notSavedAlert, animated: true) {
                        // ...
                    }
                }

                    let savedAlert = UIAlertController(title: "הצלחה", message: "יצרנו בשבילך תזכורת עבור המבחן", preferredStyle: UIAlertControllerStyle.Alert)

                    let OKAction = UIAlertAction(title: "הבנתי", style: .Default) { (action) in
                    }
                    savedAlert.addAction(OKAction)

                    self.presentViewController(savedAlert, animated: true) {
                        // ...
                    }
            }
        })
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isRefreshing {
            return self.testsArray.count
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !isRefreshing {
            let cell = tableView.dequeueReusableCellWithIdentifier("testCell", forIndexPath: indexPath) as! CustomTestCell
            cell.titleText?.text = self.testsArray[indexPath.row][1] //Subject
            cell.subtitleText!.text = self.testsArray[indexPath.row][0] //Date
            cell.titleText!.textAlignment = NSTextAlignment.Right
            cell.subtitleText!.textAlignment = NSTextAlignment.Right
            cell.titleText!.font = UIFont(name: "Alef-Bold", size: 18)
            cell.subtitleText!.font = UIFont(name: "Alef-Regular", size: 15)
            cell.backgroundColor = UIColor.clearColor()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("testCell", forIndexPath: indexPath) as! CustomTestCell
            cell.titleText!.text = "מעדכן..."
            cell.titleText!.font = UIFont(name: "Alef-Bold", size: 18)
            cell.titleText!.textAlignment = NSTextAlignment.Center
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}