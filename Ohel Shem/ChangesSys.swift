//
//  ChangesSys.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit
//import Alamofire

class ChangesSys: UITableViewController {
    //MARK: Instance variables
    var changes = [""]
    let numberToHebrewNumbers = [1:"ראשונה", 2:"שנייה", 3:"שלישית", 4:"רביעית", 5:"חמישית", 6:"שישית", 7:"שביעית", 8:"שמינית", 9:"תשיעית", 10:"עשירית", 11:"אחת-עשרה"]
    var isRefreshing = false
    var dateOfChanges = ""

    //MARK: IBOutlets
    @IBOutlet weak var refresherControl: UIRefreshControl?

    //MARK: UIView methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.addLeftMenuButton()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        self.tableView.estimatedRowHeight = 44

        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        /*let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //tableView.backgroundView = blurEffectView

        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)*/
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        isRefreshing = true
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            do {
                self.changes = try SchoolWebsiteDataManager.sharedInstance.GetChanges()
                self.dateOfChanges = try SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges()
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    //let i = 0
                    self.isRefreshing = false
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                    //self.theTextView?.attributedText = textToDisplay
                    //self.theTextView?.textAlignment = NSTextAlignment.Right
                }
            } catch{
                print(error)
            }
        }
    }

    //MARK: IBActions
    @IBAction func willRefresh(sender: UIRefreshControl){
        refreshControl!.attributedTitle! = NSAttributedString(string: "בודק שינויים")

        do{
            changes = try SchoolWebsiteDataManager.sharedInstance.GetChanges()
        } catch{
            print(error)
        }
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)

        //let formatter = NSDateFormatter()
        //formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        //NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSinceNow: 0), dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        let lastUpdated = "התעדכן לאחרונה ב: " + NSDateFormatter.localizedStringFromDate(NSDate(timeIntervalSinceNow: 0), dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)//formatter.stringFromDate(NSDate(timeIntervalSinceNow: 0))
        refreshControl!.attributedTitle! = NSAttributedString(string: lastUpdated)

        refreshControl!.endRefreshing()
    }

    //MARK: UITableViewDataSource methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!isRefreshing) {
            return changes.count == 0 ? 2 : changes.count + 1
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (!isRefreshing) {
            let cell = tableView.dequeueReusableCellWithIdentifier("changeCell", forIndexPath: indexPath) 
            if ((indexPath.row <= changes.count && changes.count == 0) || (indexPath.row < changes.count && changes.count != 0)) {
                if (changes.count > 1) {
                    cell.textLabel!.text = "שעה " + numberToHebrewNumbers[indexPath.row + 1]! + ": " + (changes[indexPath.row] == "-" ? "אין שינויים!" : changes[indexPath.row])
                    cell.textLabel?.textColor = (changes[indexPath.row] == "-" ? UIColor.blackColor() : UIColor.redColor())
                    cell.textLabel?.font = (changes[indexPath.row] == "-" ? UIFont(name:"Alef-Regular", size: 16) : UIFont(name:"Alef-Bold", size: 18))
                } else {
                    if let noChanges = changes.first where noChanges == "אין שינויים" {
                        cell.textLabel!.text = "אין שינויים"
                    } else {
                        cell.textLabel!.text = "לא ניתן היה למצוא שינויים"
                    }
                    cell.textLabel?.font = UIFont(name:"Alef-Bold", size: 16)
                }
            } else {
                //Display day of changes in last row
                let today = NSDate(timeIntervalSinceNow: 0)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                dateFormatter.timeZone = NSTimeZone.localTimeZone()
                let nowDate = dateFormatter.stringFromDate(today)
                dateFormatter.dateFormat = "HH:mm:ss"
                let nowHour = dateFormatter.stringFromDate(today)
                let dateString = ", ונלקח בתאריך \(nowDate), בשעה \(nowHour)"

                cell.textLabel!.text = dateOfChanges + dateString
                cell.textLabel?.textColor = UIColor.redColor()
                cell.textLabel?.font = UIFont(name:"Alef-Bold", size: 16)
                cell.textLabel?.numberOfLines = 0
            }

            cell.textLabel!.textAlignment = NSTextAlignment.Right
            cell.textLabel!.backgroundColor = UIColor.clearColor()
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel!.lineBreakMode = .ByWordWrapping
            cell.textLabel!.numberOfLines = 0

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("changeCell", forIndexPath: indexPath) 
            cell.textLabel!.text = "מעדכן..."
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.font = UIFont(name:"Alef-Bold", size: 14)
            cell.textLabel!.textAlignment = NSTextAlignment.Center



            return cell
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}