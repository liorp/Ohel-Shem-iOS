//
//  SlideMenu.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

class SlideMenu: AMSlideMenuLeftTableViewController {
    //MARK: IBOutlets
    @IBOutlet weak var hello: UILabel?
    @IBOutlet weak var logo: UIImageView?

    func changeInfo(notification: NSNotification){
        hello!.text = "שלום, " + (NSUserDefaults.standardUserDefaults().valueForKey("studentName") as! String)
        hello!.font = UIFont(name: "Alef-Bold", size: 25)
    }
    
    //MARK: UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hello!.text = "שלום, " + (NSUserDefaults.standardUserDefaults().valueForKey("studentName") as? String ?? "")
        hello!.textAlignment = NSTextAlignment.Right
        hello!.font = UIFont(name: "Alef-Bold", size: 25)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeInfo:", name: "infoHasChanged", object: nil)
        logo?.image = UIImage(named: "logo.gif")
        //self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Top)
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.estimatedRowHeight = 44
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    }

    //MARK: UITableViewDataSourceProtocol methods
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            cell.textLabel!.font = UIFont(name: "Alef-Bold", size: 8 * UIScreen.mainScreen().scale)
            cell.backgroundColor! = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            let image = UIImage(named: "\(indexPath.row)slidecell.png")

            let size = CGSizeApplyAffineTransform(image!.size, CGAffineTransformMakeScale(0.055 * UIScreen.mainScreen().scale, 0.055 * UIScreen.mainScreen().scale))
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

            UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
            image!.drawInRect(CGRect(origin: CGPointZero, size: size))

            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

            cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            cell.imageView!.image = scaledImage

            //(self.tableView! as CFSSpringTableView).prepareCellForShow(cell)
        } else {
            cell.textLabel!.font = UIFont(name: "Alef-Bold", size: 13 * UIScreen.mainScreen().scale)
            cell.backgroundColor! = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            let image = UIImage(named: "\(indexPath.row)slidecell.png")

            let size = CGSizeApplyAffineTransform(image!.size, CGAffineTransformMakeScale(0.1 * UIScreen.mainScreen().scale, 0.1 * UIScreen.mainScreen().scale))
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

            UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
            image!.drawInRect(CGRect(origin: CGPointZero, size: size))

            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

            cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            cell.imageView!.image = scaledImage

            //(self.tableView! as CFSSpringTableView).prepareCellForShow(cell)
        }
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.textColor = UIColor.whiteColor()

        /*UIView.animateWithDuration(0.3, delay: 0,  options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            var i = 0
            cell?.center = CGPointMake(cell!.center.x - 150, cell!.center.y)
        }) { (completed) -> Void in
            var i = 0
            cell?.center = CGPointMake(cell!.center.x + 150, cell!.center.y)
        }*/
        return indexPath
    }

    override func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.textColor = UIColor.blackColor()
        return indexPath
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.height/9
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.height/9
    }
}