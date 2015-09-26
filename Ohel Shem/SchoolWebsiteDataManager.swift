//
//  GetSchoolWebsiteData.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/11/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

private let _SchoolWebsiteDataManager = SchoolWebsiteDataManager()

class SchoolWebsiteDataManager {

    /**
    Gets the shared instance (aka Singleton) for the SchoolWebsiteDataManager class

    - returns: The shared instance (aka Singleton) for the SchoolWebsiteDataManager class
    */
    class var sharedInstance: SchoolWebsiteDataManager {
        return _SchoolWebsiteDataManager
    }

    /**
    Sends a request to Ohel-Shem's website to get an hour system, using the user's settings of class and layer

    - Parameters: 
        - weekDay:    The day for which to fetch the hours

    - returns: The hour system for the requested day, or an empty array if none exists. If weekDay == 7 (Sabbath), returns an 11 element array with "אין לימודים בשבת!"
    */
    func GetHours(weekDay : Int) throws -> [String] {
        var hours: [String] = []
        let path = NSBundle.mainBundle().pathForResource("timetable", ofType: "json")
        let jsonData = try NSData(contentsOfFile: path!, options: [NSDataReadingOptions.DataReadingMappedIfSafe])
        let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions()) as! NSArray
        
        var res = ""

        for index in 0...10 {
            if (weekDay != 7) {
                res = jsonResult[NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue - 9][NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue - 1][weekDay - 1][index] as! String
                if (res == "" || res == " " || res.characters.count == 0 || res.characters.count == 1) {
                    res = "שעה חופשית!"
                }
            } else {
                res = "אין לימודים בשבת!"
            }
            hours.append(res)
        }
        return hours
    }

    /**
    Sends a request to Ohel-Shem's website to get the string of the changes day, using the user's settings of class and layer

    - returns: The day string, e.g. ״לוח השינויים המוצג הינו רלוונטי ליום ראשון ה-״
    */
    func GetDayOfChanges() throws -> String {
        let data = try NSString(contentsOfURL: NSURL(string: "http://ohel-shem.com/php/changes/changes_sys/index.php?layer=" + String(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue))!, encoding:CFStringConvertEncodingToNSStringEncoding(0x0208))

        // Parse a string and find an element.
        let document = HTMLDocument(string: data as String)
        let changesTables = document.nodesMatchingSelector("font")
        return changesTables[2].textContent
    }

    /**
    Sends a request to Ohel-Shem's website to get the news, using the user's settings of class and layer

    - Parameters: 
        - HTMLContent:    Pass true to get the the news as an HTML string; otherwise, pass false

    - returns: The news for today, in HTML or in plain text
    */
    func GetNews(HTMLContent HTMLContent: Bool) throws -> String {
        var newsString = ""

        let data = try NSString(contentsOfURL: NSURL(string: "http://ohel-shem.com/portal4/Archive.php?" + String(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue))!, encoding:NSUTF8StringEncoding)

        // Parse a string and find an element.
        let document = HTMLDocument(string: data as String)
        let newsTable = document.firstNodeMatchingSelector("#MainBlock_Content")

        for node in newsTable.nodesMatchingSelector(".LBnews"){
            //News item
            if (HTMLContent) {
                newsString += String(node.firstNodeMatchingSelector("div").innerHTML()) + "<br>"
            } else {
                newsString += (node.firstNodeMatchingSelector("div").textContent! as NSString).substringToIndex((node.firstNodeMatchingSelector("div").textContent! as NSString).length - 15) + "\n \n"
            }

            //Hack because I should remove the פרטים נוספים
        }
        return newsString
    }

    /**
    Sends a request to Ohel-Shem's website to get a test list, using the user's settings of class and layer

    - returns: A string array of tests for the user
    */
    func GetTests() -> [String] {
        /*let data = NSString(contentsOfURL: NSURL(string: "http://www.ohel-shem.com/php/exams/?request=exams&layer=" + String(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue) + "&classn=" + String(NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue))!, encoding:CFStringConvertEncodingToNSStringEncoding(0x0208) , error: nil)

        // Parse a string and find an element.
        let document = HTMLDocument(string: data)
        let theTable = document.firstNodeMatchingSelector("tbody")
        var skipFirstRow = false
        var testsArr: [String] = []


        for node in theTable.nodesMatchingSelector("tr"){
            if (!skipFirstRow) {
                skipFirstRow = true
            } else {
                let inner = (node as HTMLNode).nodesMatchingSelector("td")
                testsArr.append("מבחן ב" + String(inner[0].textContent) + " ב" + String(inner[2].textContent))
            }
        }*/
        let testsArr = ["לוח המבחנים מושבת עד לעליית הגרסה החדשה"]
        return testsArr
    }

    /**
    Sends a request to Ohel-Shem's website to get a test date list, using the user's settings of class and layer

    - returns: A string array of tests dates for the user
    */
    func GetTestsDates() throws -> [String] {
        let data = try NSString(contentsOfURL: NSURL(string: "http://www.ohel-shem.com/php/exams/?request=exams&layer=" + String(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue) + "&classn=" + String(NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue))!, encoding:CFStringConvertEncodingToNSStringEncoding(0x0208))

        // Parse a string and find an element.
        let document = HTMLDocument(string: data as String)
        let theTable = document.firstNodeMatchingSelector("tbody")
        var skipFirstRow = false
        var testsDatesArr: [String] = []


        for node in theTable.nodesMatchingSelector("tr"){
            if (!skipFirstRow) {
                skipFirstRow = true
            } else {
                let inner = (node as! HTMLNode).nodesMatchingSelector("td")
                testsDatesArr.append("ב" + String(inner[2].textContent))
            }
        }
        return testsDatesArr
    }

    /**
    Sends a request to Ohel-Shem's website to get the numeber of tests, using the user's settings of class and layer. Used for numberOfRows in TestSys

    - returns: The number of tests for the user
    */
    func NumberOfTests() throws -> Int {
        let data = try NSString(contentsOfURL: NSURL(string: "http://www.ohel-shem.com/php/exams/?request=exams&layer=" + String(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue) + "&classn=" + String(NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue))!, encoding:CFStringConvertEncodingToNSStringEncoding(0x0208))

        // Parse a string and find an element.
        let document = HTMLDocument(string: data as String)
        let theTable = document.firstNodeMatchingSelector("tbody")
        //var skipFirstRow = false

        return theTable.nodesMatchingSelector("tr").count - 1
    }

    /**
    Sends a request to Ohel-Shem's website to get today's changes, using the user's settings of class and layer

    - returns: A string array of today's changes for the user
    */
    func GetChanges () throws -> [String]{
        //let data = NSString(contentsOfURL: NSURL(string: "http://ohel-shem.com/php/changes/changes_sys/index.php?layer=" + String(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue))!, encoding:CFStringConvertEncodingToNSStringEncoding(0x0208) , error: nil)
        let data = try NSString(contentsOfURL: NSURL(string: "http://ohel-shem.com/php/changes/changes_sys/index.php?layer=" + String(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue))!, encoding: CFStringConvertEncodingToNSStringEncoding(0x0208))


        // Parse a string and find an element.
        let document = HTMLDocument(string: data as String)
        let theTable = document.firstNodeMatchingSelector("table[bgcolor=white]")
        var changes: [String] = []

        if (theTable != nil) {
            if (!theTable.textContent.isEmpty) {
                var skippedRowOne = false
                var skippedColumnOne = false
                //var hour = 1
                //var firstTime = true
                var classNum = 1

                for row in theTable.nodesMatchingSelector("tr") {
                    if (!skippedRowOne) {
                        skippedRowOne = true
                    } else {
                        for cell in row.nodesMatchingSelector("td") {
                            if (!skippedColumnOne) {
                                skippedColumnOne = true
                            } else {
                                if classNum == NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue {
                                    changes.append(cell.textContent!)
                                }
                                classNum++
                            }
                        }
                    }
                    classNum = 1
                    skippedColumnOne = false
                }
            }
        }

        //Perhaps no changes?
        if changes.count == 0 && data.containsString("אין שינויים") {
            return ["אין שינויים"]
        }
        
        return changes
    }
}

