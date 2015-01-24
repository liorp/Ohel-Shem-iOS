//
//  ChangesSys.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

class HourSys: UITableViewController {

    var jsonResult: NSArray?
    var weekDay: Int?
    var hours: [String]?
    let numberToHebrewNumbers = [1:"ראשונה", 2:"שנייה", 3:"שלישית", 4:"רביעית", 5:"חמישית", 6:"שישית", 7:"שביעית", 8:"שמינית", 9:"תשיעית", 10:"עשירית", 11:"אחת-עשרה"]
    let numberToHebrewNumbersMale = [1:"ראשון", 2:"שני", 3:"שלישי", 4:"רביעי", 5:"חמישי", 6:"שישי", 7:"שבת"]
    var itemIndex: Int?

    func getNextHoliday(month: Int, day: Int) -> NSDate! {
        var hebrew = NSCalendar(calendarIdentifier: NSHebrewCalendar)
        var unitFlags: NSCalendarUnit = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear

        var componentsOfToday = hebrew?.components(unitFlags, fromDate: NSDate(timeIntervalSinceNow: 0))
        var componentsOfFutureDate = NSDateComponents()
        componentsOfFutureDate.month = month
        componentsOfFutureDate.day = day

        var AlreadyPassedDate: Bool = (componentsOfFutureDate.month < componentsOfToday!.month || (componentsOfFutureDate.month == componentsOfToday!.month && componentsOfFutureDate.day < componentsOfToday!.day ))

        if  (AlreadyPassedDate){
            componentsOfFutureDate.year = componentsOfToday!.year + 1
        } else {
            componentsOfFutureDate.year = componentsOfToday!.year
        }

        return hebrew?.dateFromComponents(componentsOfFutureDate)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        //Calculate date of today
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = NSDate(timeIntervalSinceNow: 0)
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar!.components(.WeekdayCalendarUnit, fromDate: todayDate)
        weekDay = myComponents.weekday
        hours = SchoolWebsiteDataManager.sharedInstance.GetHours(itemIndex! + 1)
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.estimatedRowHeight = 44
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("hourCell", forIndexPath: indexPath) as UITableViewCell
        let display = hours![indexPath.row]

        cell.textLabel!.text = "שעה " + numberToHebrewNumbers[indexPath.row + 1]! + ": \(display)"
        cell.textLabel!.textAlignment = NSTextAlignment.Right
        cell.textLabel!.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        println("ran")
        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.parentViewController!.parentViewController!.navigationItem.title = "יום " + numberToHebrewNumbersMale[itemIndex! + 1]!
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addLeftMenuButton()

        /*let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.backgroundView = blurEffectView

        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)*/
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.automaticallyAdjustsScrollViewInsets = true
        self.tableView.contentInset = UIEdgeInsetsMake(self.parentViewController!.parentViewController!.navigationController!.navigationBar.frame.height + 20, 0, 0, 0)
    }
}