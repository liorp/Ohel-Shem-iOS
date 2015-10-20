//
//  FirstTimeHere.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 1/2/15.
//  Copyright (c) 2015 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

class FirstTimeHere: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    //MARK: IBOutlets
    @IBOutlet var userField: UITextField?
    @IBOutlet var classField: UITextField?
    @IBOutlet var userLabel: UILabel?
    @IBOutlet var classLabel: UILabel?

    @IBOutlet var goToApp: UIButton?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var textView: UITextView?
    @IBOutlet var shimmeringView: FBShimmeringView?

    @IBOutlet var classAndLayerInput: UIPickerView? = UIPickerView()

    //MARK: Instance properties
    var classNum: String = "4"
    var layerNum: String = "י\"ב"

    let classes = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    let layers = [9:"ט׳",10:"י׳",11:"י״א", 12:"י״ב"]
    let oppositeLayers = ["ט׳":9, "י׳":10, "י״א":11, "י״ב":12]
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

    //MARK: UITextFieldDelegate Methods
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField.text == classField?.text) {
            return false
        } else {
            return true
        }
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if (classField?.text?.characters.count > 2 && userField?.text?.characters.count > 0) {
            self.goToApp?.enabled = true
        } else {
            self.goToApp?.enabled = false
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == classField?.text) {
            //self.updateClassandLayer(textField)
        }
    }

    func hideKeyboard(){
        self.userField?.resignFirstResponder()
        self.userLabel?.resignFirstResponder()
        self.classField?.resignFirstResponder()
        self.classLabel?.resignFirstResponder()

        self.userField?.endEditing(true)
        self.userLabel?.endEditing(true)
        self.classField?.endEditing(true)
        self.classLabel?.endEditing(true)

        if (classField?.text?.characters.count > 2 && userField?.text?.characters.count > 0) {
            self.goToApp?.enabled = true
        } else {
            self.goToApp?.enabled = false
        }
    }

    //MARK: UIView methods
    override func shouldAutorotate() -> Bool {
        return false
    }

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

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        gestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gestureRecognizer)

        if (itemIndex == 3) {
            self.goToApp?.hidden = false
            self.userField?.hidden = false
            self.userLabel?.hidden = false
            self.classField?.hidden = false
            self.classLabel?.hidden = false
        } else {
            self.goToApp?.hidden = true
            self.userField?.hidden = true
            self.userLabel?.hidden = true
            self.classField?.hidden = true
            self.classLabel?.hidden = true
        }

        textView!.font = UIFont(name: "Alef-Regular", size: 22)

        if (itemIndex == 0) {
            //animateViewsIntoView()

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

        //classAndLayerInput?.removeFromSuperview()

        //self.view.setNeedsUpdateConstraints()
        //self.view.setNeedsLayout()

        if itemIndex == 3 {
            classAndLayerInput?.dataSource = self
            classAndLayerInput?.delegate = self
            classField!.inputView = classAndLayerInput
            let doneButton = UIBarButtonItem(title: "סיימתי", style: UIBarButtonItemStyle.Done, target: self, action: "hideKeyboard")
            let middleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
            let toolbar = UIToolbar()
            toolbar.barStyle = UIBarStyle.Default
            toolbar.translucent = true
            toolbar.setItems([middleSpace, doneButton], animated: false)
            toolbar.sizeToFit()
            classField!.inputAccessoryView = toolbar

            self.setPreselectedPicker(UITextField())

            self.goToApp?.enabled = false
        }
    }

    func animateViewsIntoView() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6.0, options: [UIViewAnimationOptions()], animations: { () -> Void in
            //let i = 0
            self.goToApp?.frame = CGRectMake(self.goToApp!.frame.origin.x, self.goToApp!.frame.origin.y, self.goToApp!.frame.size.width * 1.5, self.goToApp!.frame.size.height * 1.5)
            }) { (completed) -> Void in
                //let i = 1
        }
    }

    //MARK: UIPickerViewDataSource Protocol methods

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return classes.count
        } else {
            return layers.count
        }
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return classes[row]
        } else {
            return layers[row + 9]
        }
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            classNum = String(row + 1)
        } else {
            layerNum = String(layers[row + 9]!)
        }
        classField?.text = String(layerNum + " " + classNum)

    }

    //MARK: IBActions

    @IBAction func setPreselectedPicker(sender: UITextField){
        self.classAndLayerInput?.selectRow(4 - 1, inComponent: 0, animated: true)
        self.classAndLayerInput?.selectRow(12 - 9, inComponent: 1, animated: true)
    }

    @IBAction func updateClassandLayer(sender: UITextField){
        NSUserDefaults.standardUserDefaults().setValue(classAndLayerInput!.selectedRowInComponent(0) + 1, forKey: "classNum")
        //NSUbiquitousKeyValueStore.defaultStore().setValue(sender.text, forKey: "classNum")
        NSUserDefaults.standardUserDefaults().synchronize()
        //NSUbiquitousKeyValueStore.defaultStore().synchronize()

        NSUserDefaults.standardUserDefaults().setValue(classAndLayerInput!.selectedRowInComponent(1) + 9, forKey: "layerNum")
        //NSUbiquitousKeyValueStore.defaultStore().setValue(sender.text, forKey: "layerNum")
        NSUserDefaults.standardUserDefaults().synchronize()
        //NSUbiquitousKeyValueStore.defaultStore().synchronize()
        /*classAndLayerInput?.endEditing(true)
        classNum?.endEditing(true)
        layerNum?.endEditing(true)*/

        NSUserDefaults.standardUserDefaults().setValue(userField?.text, forKey: "studentName")
        NSUserDefaults.standardUserDefaults().synchronize()


        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "infoHasChanged", object: nil))
        self.hideKeyboard()
    }


    @IBAction func showApp() {
        updateClassandLayer(UITextField())
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "seenTutorial")
        NSUserDefaults.standardUserDefaults().synchronize()

        self.dismissViewControllerAnimated(true, completion: { () -> Void in

            NSNotificationCenter.defaultCenter().postNotificationName("finishedTutorial", object: nil)
        })
    }
    
    /*override func supportedInterfaceOrientations() -> Int {
    return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }*/
}