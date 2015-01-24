//
//  FirstTimeHere.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/2/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

class FirstTimeHere: UIViewController {

    var itemIndex: Int = 0

    var currentText: String = "" {

        didSet {

            if let textView1 = textView {
                textView1.text = currentText
            }

        }
    }

    var imageName: String = "" {

        didSet {

            if let imageView1 = imageView {
                imageView1.image = UIImage(named: imageName)
            }
            
        }
    }

    @IBOutlet var usernameField: UITextField?
    @IBOutlet var passwordField: UITextField?
    @IBOutlet var usernameLabel: UILabel?
    @IBOutlet var passwordLabel: UILabel?

    @IBOutlet var goToApp: UIButton?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var textView: UITextView?
    @IBOutlet var shimmeringView: FBShimmeringView?

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView!.image = UIImage(named: imageName)
        textView!.text = currentText

        var gestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        gestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gestureRecognizer)

        if (itemIndex == 3) {
            self.goToApp?.hidden = false
            self.usernameField?.hidden = false
            self.usernameLabel?.hidden = false
            self.passwordField?.hidden = false
            self.passwordLabel?.hidden = false
        } else {
            self.goToApp?.hidden = true
            self.usernameField?.hidden = true
            self.usernameLabel?.hidden = true
            self.passwordField?.hidden = true
            self.passwordLabel?.hidden = true
        }

        textView!.font = UIFont(name: "Alef-Regular", size: 22)

        if (itemIndex == 0) {
            //animateViewsIntoView()
            self.goToApp?.hidden = false

            shimmeringView?.hidden = false

            shimmeringView!.contentView = textView;

            shimmeringView!.shimmeringDirection = FBShimmerDirection.Left
            shimmeringView!.shimmeringHighlightLength = 0.5
            shimmeringView!.shimmeringSpeed = 70
            shimmeringView!.shimmeringPauseDuration = 0.2

            // Start shimmering.
            shimmeringView!.shimmering = true

            textView!.font = UIFont(name: "Alef-Regular", size: 50)

        } else {
            shimmeringView?.hidden = true
        }
        
        textView?.textAlignment = NSTextAlignment.Center
    }

    func hideKeyboard(){
        self.usernameField?.resignFirstResponder()
        self.usernameLabel?.resignFirstResponder()
        self.passwordField?.resignFirstResponder()
        self.passwordLabel?.resignFirstResponder()

        self.usernameField?.endEditing(true)
        self.usernameLabel?.endEditing(true)
        self.passwordField?.endEditing(true)
        self.passwordLabel?.endEditing(true)
    }

    func animateViewsIntoView() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6.0, options: .allZeros, animations: { () -> Void in
            let i = 0
            self.goToApp?.frame = CGRectMake(self.goToApp!.frame.origin.x, self.goToApp!.frame.origin.y, self.goToApp!.frame.size.width * 1.5, self.goToApp!.frame.size.height * 1.5)
        }) { (completed) -> Void in
            let i = 1
        }
    }

    @IBAction func showApp() {
        //let theAppVC = self.storyboard!.instantiateViewControllerWithIdentifier("StartTheApp") as UINavigationController
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //NSUserDefaults.standardUserDefaults().setBool(true, forKey: "seenTutorial")
        })
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}