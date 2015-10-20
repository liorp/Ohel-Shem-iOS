//
//  ViewController.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/30/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import UIKit

class MainViewController: AMSlideMenuMainViewController {
    //MARK: UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    //MARK: AMSlideMenuMainViewController methods
    override func configureLeftMenuButton(button: UIButton!) {
        var frame = button.frame
        frame = CGRectMake(0, 0, 25, 20)
        button.frame = frame
        button.backgroundColor = UIColor.clearColor()
        button.setImage(UIImage(named: "list23.png"), forState: UIControlState.Normal)
    }

    override func segueIdentifierForIndexPathInLeftMenu(indexPath: NSIndexPath!) -> String! {
        var theSegue:String!
        switch (indexPath!.row) {
        case 0:
            theSegue = "toMainPage"
            break
        case 1:
            theSegue = "toChanges"
            break
        case 2:
            theSegue = "toHour"
            break
        case 3:
            theSegue = "toBell"
            break
        case 4:
            theSegue = "toTest"
            break
        case 5:
            theSegue = "toNews"
            break
        case 6:
            theSegue = "toTerms"
            break
        case 7:
            theSegue = "toAbout"
            break
        case 8:
            theSegue = "toSettings"
            break
        default:
            theSegue = "toMainPage"
            break
        }
        return theSegue
    }

    override func leftMenuWidth() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            return UIScreen.mainScreen().bounds.width / 1.5
        } else {
            return UIScreen.mainScreen().bounds.width / 2.5
        }
    }

    override func deepnessForLeftMenu() -> Bool {
        return false
    }
}

