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

extension String {
    func stripCharactersInSet(chars: [Character]) -> String {
        return String(filter(self) {find(chars, $0) == nil})
    }
}

class TestSys: UITableViewController, UIAlertViewDelegate {

    @IBOutlet weak var refresherControl: UIRefreshControl?

    var testsArr  = [""]
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

        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.estimatedRowHeight = 60
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        isRefreshing = true
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            self.testsArr = SchoolWebsiteDataManager.sharedInstance.GetTests()
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                let i = 0
                self.isRefreshing = false
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                //self.theTextView?.attributedText = textToDisplay
                //self.theTextView?.textAlignment = NSTextAlignment.Right
            }
        }
    }

    @IBAction func willRefresh(sender: UIRefreshControl){
        refreshControl!.attributedTitle! = NSAttributedString(string: "בודק מבחנים")

        testsArr = SchoolWebsiteDataManager.sharedInstance.GetTests()
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)

        let formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        let lastUpdated = "התעדכן לאחרונה ב: " + formatter.stringFromDate(NSDate(timeIntervalSinceNow: 0))
        refreshControl!.attributedTitle! = NSAttributedString(string: lastUpdated)

        refreshControl!.endRefreshing()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = self.tableView.cellForRowAtIndexPath(indexPath)
        let titleSpaceSeperated = ((selectedCell! as CustomTestCell).titleText!.text! as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let subtitleSpaceSeperated = ((selectedCell! as CustomTestCell).subtitleText!.text! as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        if (objc_getClass("UIAlertController") != nil) {
            var saveAlert: UIAlertController

            //If it's a moed b we display moed b
            if (String(titleSpaceSeperated[1] as NSString) == "במועד") {
                saveAlert = UIAlertController(title: "רוצה שאזכיר לך לפני?", message: ("על המבחן " + String(titleSpaceSeperated[1] as NSString) + " " + String(titleSpaceSeperated[2] as NSString)), preferredStyle: UIAlertControllerStyle.Alert)

            } else {
                saveAlert = UIAlertController(title: "רוצה שאזכיר לך לפני?", message: ("על המבחן " + String(titleSpaceSeperated[1] as NSString)), preferredStyle: UIAlertControllerStyle.Alert)
            }

            let cancelAction = UIAlertAction(title: "לא", style: .Cancel) { (action) in
                selectedCell!.setSelected(false, animated: false)
            }
            saveAlert.addAction(cancelAction)

            let OKAction = UIAlertAction(title: "כן", style: .Default) { (action) in
                let daysTextField = saveAlert.textFields![0] as UITextField
                let num = daysTextField.text!.toInt()
                selectedCell?.setSelected(false, animated: false)
                self.haveAReminder(subtitleSpaceSeperated as [String], subject: titleSpaceSeperated as [String], numberOfDaysBefore: num!)
            }

            OKAction.enabled = false

            saveAlert.addAction(OKAction)

            saveAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "כמה ימים לפני?"

                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                    OKAction.enabled = (textField.text != "" && textField.text.toInt() != nil)
                })
            }
            
            self.presentViewController(saveAlert, animated: true) {
                // ...
            }
        } else {
            var saveAlert: UIAlertView
            if (String(titleSpaceSeperated[1] as NSString) == "במועד") {
                let message = ("על המבחן " + String(titleSpaceSeperated[1] as NSString) + " " + String(titleSpaceSeperated[2] as NSString))
                saveAlert = UIAlertView(title: "רוצה שאזכיר לך לפני?", message: message, delegate: self, cancelButtonTitle: "כן", otherButtonTitles: "לא")

            } else {
                let message = "על המבחן " + String(titleSpaceSeperated[1] as NSString)
                saveAlert = UIAlertView(title: "רוצה שאזכיר לך לפני?", message: message, delegate: self, cancelButtonTitle: "כן", otherButtonTitles: "לא")
            }
            saveAlert.alertViewStyle = UIAlertViewStyle.PlainTextInput
            saveAlert.show()
        }
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (alertView.textFieldAtIndex(0)!.text != "" && alertView.textFieldAtIndex(0)!.text.toInt() != nil) {
            //haveAReminder(subtitleSpaceSeperated as [String], subject: titleSpaceSeperated as [String], numberOfDaysBefore: alertView.textFieldAtIndex(0).text.toInt()!)
        } else {

        }
    }

    func haveAReminder(date: [String], subject: [String], numberOfDaysBefore days: Int) {
        var dateComponenta = NSDateComponents()
        let year = date[4] as NSString
        let month = self.hebrewMonthToNumber[(date[3].stripCharactersInSet([","]) as NSString)]
        let day = date[2].stripCharactersInSet(["ה", "-"]) as NSString

        dateComponenta.day = day.integerValue - days
        dateComponenta.month = month!
        dateComponenta.year = year.integerValue

        let dateOfReminder = NSCalendar.currentCalendar().dateFromComponents(dateComponenta)

        var eventStore : EKEventStore = EKEventStore()
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        eventStore.requestAccessToEntityType(EKEntityTypeReminder, completion: {
            granted, error in
            if (granted) && (error == nil) {

                var reminder = EKReminder(eventStore: eventStore)

                reminder.title = "מבחן " + (String(subject[1] as NSString) == "במועד" ? (String(subject[1] as NSString) + " " + String(subject[2] as NSString)) : (String(subject[1] as NSString)))
                reminder.notes = "צריך ללמוד כדי להצליח!"
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                reminder.startDateComponents = dateComponenta
                reminder.dueDateComponents = dateComponenta

                var error: NSError?
                var didSave = eventStore.saveReminder(reminder, commit: true, error: &error)
                if (!didSave) {
                    print("not saved " + error!.localizedDescription)

                    let notSavedAlert = UIAlertController(title: "שגיאה", message: "לא יכולנו ליצור תזכורת עבור המבחן", preferredStyle: UIAlertControllerStyle.Alert)

                    let OKAction = UIAlertAction(title: "אוף", style: .Default) { (action) in
                    }
                    notSavedAlert.addAction(OKAction)

                    self.presentViewController(notSavedAlert, animated: true) {
                        // ...
                    }
                } else {
                    print("saved")

                    let savedAlert = UIAlertController(title: "הצלחה", message: "יצרנו בשבילך תזכורת עבור המבחן", preferredStyle: UIAlertControllerStyle.Alert)

                    let OKAction = UIAlertAction(title: "הבנתי", style: .Default) { (action) in
                    }
                    savedAlert.addAction(OKAction)

                    self.presentViewController(savedAlert, animated: true) {
                        // ...
                    }
                }
            }
        })
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isRefreshing {
            return SchoolWebsiteDataManager.sharedInstance.NumberOfTests()
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        if !isRefreshing {
            let cell = tableView.dequeueReusableCellWithIdentifier("testCell", forIndexPath: indexPath) as CustomTestCell
            let words = (testsArr[indexPath.row] as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            //If it's a moed b we display moed b
            var subtitle : String = ""
            if (String(words[1] as NSString) == "במועד") {
                for (var i = 3; i < 8; i++){
                    subtitle += String(words[i] as NSString) + " "
                }
                cell.titleText!.text = String(words[0] as NSString) + " " + String(words[1] as NSString) + " " + String(words[2] as NSString)
            } else {
                for (var i = 2; i < 7; i++){
                    subtitle += String(words[i] as NSString) + " "
                }
                cell.titleText!.text = String(words[0] as NSString) + " " + String(words[1] as NSString)
            }
            cell.subtitleText!.text = subtitle
            cell.titleText!.textAlignment = NSTextAlignment.Right
            cell.subtitleText!.textAlignment = NSTextAlignment.Right
            cell.titleText!.font = UIFont(name: "Alef-Bold", size: 18)
            cell.subtitleText!.font = UIFont(name: "Alef-Regular", size: 15)
            cell.backgroundColor = UIColor.clearColor()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("testCell", forIndexPath: indexPath) as CustomTestCell
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