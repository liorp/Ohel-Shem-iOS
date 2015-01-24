//
//  SchoolTerms.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/31/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

class SchoolTerms: UIViewController {

    @IBOutlet weak var terms: UIWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //terms! = SchoolWebsiteDataManager.sharedInstance.GetTerms()

        let termsURL = NSURL(string: "http://www.ohel-shem.com/portal4/files/files/Ohel_Shem_Yedion_2014_Hagaha3.pdf")
        let theRequest = NSURLRequest(URL: termsURL!)
        terms!.loadRequest(theRequest)
        terms!.scalesPageToFit = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.addLeftMenuButton()
    }
}