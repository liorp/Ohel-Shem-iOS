//
//  ChangesSys.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ChangesSys: UITableViewController {

    @IBOutlet weak var refresherControl: UIRefreshControl?

    var changes = [""]
    let numberToHebrewNumbers = [1:"ראשונה", 2:"שנייה", 3:"שלישית", 4:"רביעית", 5:"חמישית", 6:"שישית", 7:"שביעית", 8:"שמינית", 9:"תשיעית", 10:"עשירית", 11:"אחת-עשרה"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        changes = SchoolWebsiteDataManager.sharedInstance.GetChanges()

        self.addLeftMenuButton()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.estimatedRowHeight = 44
    }

    @IBAction func willRefresh(sender: UIRefreshControl){
        refreshControl!.attributedTitle! = NSAttributedString(string: "בודק שינויים")

        changes = SchoolWebsiteDataManager.sharedInstance.GetChanges()

        //getChanges()
        self.tableView.reloadData()

        let formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        let lastUpdated = "התעדכן לאחרונה ב: " + formatter.stringFromDate(NSDate(timeIntervalSinceNow: 0))
        refreshControl!.attributedTitle! = NSAttributedString(string: lastUpdated)

        refreshControl!.endRefreshing()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return changes.count == 0 ? 2 : changes.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("changeCell", forIndexPath: indexPath) as UITableViewCell
        if (indexPath.row != changes.count+1) {
            if (changes.count > 1) {
                cell.textLabel!.text = "שעה " + numberToHebrewNumbers[indexPath.row + 1]! + ": " + (changes[indexPath.row] == "-" ? "אין שינויים!" : changes[indexPath.row])
            } else {
                cell.textLabel!.text = "לא ניתן היה למצוא שינויים"
            }
        } else {
            //Display day of changes in last row
            cell.textLabel!.text = SchoolWebsiteDataManager.sharedInstance.GetDayOfChanges()
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.font = UIFont(name:"Alef-Bold", size: 14)
        }

        cell.textLabel!.textAlignment = NSTextAlignment.Right
        cell.textLabel!.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        /*let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //tableView.backgroundView = blurEffectView
        
        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)*/
    }
}