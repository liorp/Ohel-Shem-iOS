//
//  GetSchoolWebsiteData.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/11/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//
// The new SchoolWebsiteDataManager - Designed for Portal 6


import Foundation
import UIKit
import SwiftyJSON
import Alamofire

private let _SchoolWebsiteDataManagerPortal6 = SchoolWebsiteDataManagerPortal6()

class SchoolWebsiteDataManagerPortal6 {

    /**
    Gets the shared instance (aka Singleton) for the SchoolWebsiteDataManagerPortal6 class

    - returns: The shared instance (aka Singleton) for the SchoolWebsiteDataManagerPortal6 class
    */
    class var sharedInstance: SchoolWebsiteDataManagerPortal6 {
        return _SchoolWebsiteDataManagerPortal6
    }

    /**
    Sends a request to Ohel-Shem's website (Portal 6) to get an hour system, using the user's settings of class and layer

    - Parameters: 
        - weekDay:    The day for which to fetch the hours

    - returns: The hour system for the requested day, or an empty array if none exists. If weekDay == 7 (Sabbath), returns an 11 element array with "אין לימודים בשבת!"
    */
    func GetHours(weekDay: Int) throws -> [String] {
        
        var hours: [String] = []
        if (weekDay == 7) {
            for _ in 0...10 {
                hours.append("אין לימודים בשבת!")
            }
            return hours
        }
        let request = NSMutableURLRequest(URL: NSURL(string: "http://ohel-shem.com/portal6/system/mobile_api_v1/schedule.php")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "identity=208277632&password=123456789".dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        if let data = NSURLSession.requestSynchronousJSON(request) {
            let json = JSON(data)
            for hour in json {
                guard let day = ((hour.1)["day"]).string else { continue }
                if Int(day) == weekDay {
                    if let sub = ((hour.1)["sub"]).string {
                        hours.append(sub)
                    } else {
                        hours.append("שעה חופשית!")
                    }
                }
            }
            return hours
        } else {
            for _ in 0...10 {
                hours.append("קרתה שגיאה")
            }
            return hours
        }
    }

    /**
    Sends a request to Ohel-Shem's website (Portal 6) to get the string of the changes day, using the user's settings of class and layer

    - returns: The day string, e.g. ״לוח השינויים המוצג הינו רלוונטי ליום ראשון ה-״
    */
    func GetDayOfChanges() throws -> String {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://ohel-shem.com/portal6/system/mobile_api_v1/changes_date.php")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "identity=208277632&password=123456789".dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        if let data = NSURLSession.requestSynchronousJSON(request) {
            let json = JSON(data)
            if let date = (json["Date"]).string {
                return date
            } else {
                throw NSError(domain: "OhelShem", code: 404, userInfo: [NSLocalizedDescriptionKey : "לא היה ניתן להשיג את תאריך השינויים מהשרת."])
            }
        } else {
            throw NSError(domain: "OhelShem", code: 404, userInfo: [NSLocalizedDescriptionKey : "לא היה ניתן להשיג את תאריך השינויים מהשרת."])
        }

    }

    /**
    Sends a request to Ohel-Shem's website (Portal 6) to get the news, using the user's settings of class and layer

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
    Gets the local file of tests- parses and returns Array of Array Of String- each sub-array has 2 elements- date and subject.

    - returns: An Array of Array of String of tests for the user
    */
    func GetTests() throws -> [[String]] {
        let classNum = NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue
        let layer = NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue
        let path = NSBundle.mainBundle().pathForResource("tests\(layer)", ofType: "json")
        let jsonData = try NSData(contentsOfFile: path!, options: [NSDataReadingOptions.DataReadingMappedIfSafe])
        let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions()) as! NSArray
        if let tests = jsonResult[classNum-1] as? [[String]] {
            return tests
        } else {
            return [[""]]
        }
    }

    /**
    Sends a request to Ohel-Shem's website (Portal 6) to get today's changes, using the user's settings of class and layer

    - returns: A string array of today's changes for the user
    */
    func GetChanges () throws -> [String]{
        let request = NSMutableURLRequest(URL: NSURL(string: "http://ohel-shem.com/portal6/system/mobile_api_v1/changes.php")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "identity=208277632&password=123456789".dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var changes: [String] = [String](count: 10, repeatedValue: "")
        if let data = NSURLSession.requestSynchronousJSON(request) {
            let json = JSON(data)
            print(json)
            for hour in json {
                if let change = ((hour.1)["content"]).string {
                    changes[(hour.1)["hour"].intValue] = change
                }
            }
            //Perhaps no changes?
            if changes == [String](count: 10, repeatedValue: "") {
                return ["אין שינויים"]
            }
            return changes
        } else {
            for _ in 0...10 {
                changes.append("קרתה שגיאה")
            }
            return changes
        }
    }
}

