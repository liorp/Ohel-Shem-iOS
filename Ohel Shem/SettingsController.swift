//
//  SettingsController.swift
//  Ohel Shem
//
//  Created by Lior Pollak on 12/31/14.
//  Copyright (c) 2014 Lior Pollak. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var hello: UILabel?
    @IBOutlet weak var versionLabel: UILabel?
    @IBOutlet weak var userName: UITextField?
    @IBOutlet weak var password: UITextField?
    @IBOutlet weak var name: UITextField?
    @IBOutlet weak var layerNum: UITextField?
    @IBOutlet weak var classNum: UITextField?
    @IBOutlet weak var classAndLayerInput: UIPickerView?

    let classes = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    let layers = [9:"ט׳",10:"י׳",11:"י״א", 12:"י״ב"]
    let oppositeLayers = ["ט׳":9, "י׳":10, "י״א":11, "י״ב":12]

    var currentContentInset: UIEdgeInsets?
    var activeTextField: UITextField?

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets

        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        let activeTextFieldRect: CGRect? = activeTextField?.frame
        let activeTextFieldOrigin: CGPoint? = activeTextFieldRect?.origin
        if (!CGRectContainsPoint(aRect, activeTextFieldOrigin!)) {
            tableView.scrollRectToVisible(activeTextFieldRect!, animated:true)
        }
    }

    //MARK: - UITextField Delegate Methods

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField.text == classNum?.text || textField.text == layerNum?.text) {
            return false
        } else {
            return true
        }
    }

    func textFieldDidBeginEditing(textField: UITextField!) {
        activeTextField = textField
        //tableView.scrollEnabled = true
    }

    func textFieldDidEndEditing(textField: UITextField!) {
        activeTextField = nil
        //tableView.scrollEnabled = false
    }

    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(sender: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        tableView.contentInset = currentContentInset!
        tableView.scrollIndicatorInsets = contentInsets
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        currentContentInset = tableView.contentInset
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)

        hello!.numberOfLines = 0
        hello!.text = "שלום, "
        hello!.text = hello!.text! + (NSUserDefaults.standardUserDefaults().valueForKey("studentName")? as String)
        hello!.text = hello!.text! +  " מכיתה "
        hello!.text = hello!.text! +  layers[NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue]!
        hello!.text = hello!.text! +  " "
        hello!.text = hello!.text! +  String(NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue)
        hello!.text = hello!.text! +  ","
        hello!.text = hello!.text! +  " \n "
        hello!.text = hello!.text! +  "כאן נמצאות ההגדרות שלך"

        classNum!.inputView = classAndLayerInput
        layerNum!.inputView = classAndLayerInput
        let doneButton = UIBarButtonItem(title: "סיימתי", style: UIBarButtonItemStyle.Done, target: self, action: "updateClassandLayer:")
        let middleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        var toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.translucent = true
        toolbar.setItems([middleSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        layerNum?.inputAccessoryView = toolbar
        classNum?.inputAccessoryView = toolbar

        self.addLeftMenuButton()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.name!.text = NSUserDefaults.standardUserDefaults().valueForKey("studentName") as String
        self.layerNum!.text = layers[NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue]
        self.classNum!.text = String(NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue)

        if let username: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("username") {
            self.userName!.text = String(NSUserDefaults.standardUserDefaults().valueForKey("username")! as NSString)
        }
        if let password: AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("password") {
            self.password!.text = String(NSUserDefaults.standardUserDefaults().valueForKey("password")! as NSString)
        }

        self.userName!.autocorrectionType = UITextAutocorrectionType.No

        /*let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.backgroundView = blurEffectView

        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)*/

        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        hello!.font = UIFont(name: "Alef-Bold", size: 18 + 3 * UIScreen.mainScreen().scale)
        hello!.lineBreakMode = .ByWordWrapping
        hello!.numberOfLines = 0

        var gestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        gestureRecognizer.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(gestureRecognizer)

        self.tableView.rowHeight = 44

        self.tableView.estimatedRowHeight = 44

        self.setPreselectedPicker(UITextField())

        let versionNumber: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String

        let buildNumber: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as String

        let versionBuildString = "אהל שם. גרסה: \(versionNumber) (\(buildNumber)). נוצר עם ♥"

        versionLabel!.text = versionBuildString

        versionLabel!.numberOfLines = 0

        versionLabel!.font = UIFont(name: "Alef-Bold", size: 14)
    }

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

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if component == 0 {
            return classes[row]
        } else {
            return layers[row + 9]
        }
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            classNum?.text = String(row + 1)
        } else {
            layerNum?.text = String(layers[row + 9]!)
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        layerNum?.resignFirstResponder()
        classNum?.resignFirstResponder()
        classAndLayerInput?.resignFirstResponder()
        name?.resignFirstResponder()
        password?.resignFirstResponder()
        userName?.resignFirstResponder()
        self.view.resignFirstResponder()
        self.tableView.resignFirstResponder()

        /*classAndLayerInput?.endEditing(true)
        classNum?.endEditing(true)
        layerNum?.endEditing(true)
        name?.endEditing(true)
        self.view.endEditing(true)
        self.tableView.endEditing(true)*/
    }

    func hideKeyboard(){
        layerNum?.resignFirstResponder()
        classNum?.resignFirstResponder()
        classAndLayerInput?.resignFirstResponder()
        name?.resignFirstResponder()
        password?.resignFirstResponder()
        userName?.resignFirstResponder()
        self.view.resignFirstResponder()
        self.tableView.resignFirstResponder()

        /*classAndLayerInput?.endEditing(true)
        classNum?.endEditing(true)
        layerNum?.endEditing(true)
        name?.endEditing(true)
        self.view.endEditing(true)
        self.tableView.endEditing(true)*/
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel!.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.font = UIFont(name: "Alef-Bold", size: 18)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(animated)
    }

    @IBAction func setPreselectedPicker(sender: UITextField){
        self.classAndLayerInput?.selectRow(NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue - 1, inComponent: 0, animated: true)
        self.classAndLayerInput?.selectRow(NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue - 9, inComponent: 1, animated: true)
    }

    @IBAction func updateName(sender: UITextField) {
        NSUserDefaults.standardUserDefaults().setValue(sender.text, forKey: "studentName")
        //NSUbiquitousKeyValueStore.defaultStore().setValue(sender.text, forKey: "studentName")
        NSUserDefaults.standardUserDefaults().synchronize()
        //NSUbiquitousKeyValueStore.defaultStore().synchronize()

        hello!.text = "שלום, "
        hello!.text = hello!.text! + (NSUserDefaults.standardUserDefaults().valueForKey("studentName")? as String)
        hello!.text = hello!.text! +  " מכיתה "
        hello!.text = hello!.text! +  layers[NSUserDefaults.standardUserDefaults().valueForKey("layerNum")!.integerValue]!
        hello!.text = hello!.text! +  " "
        hello!.text = hello!.text! +  String(NSUserDefaults.standardUserDefaults().valueForKey("classNum")!.integerValue)
        hello!.text = hello!.text! +  ","
        hello!.text = hello!.text! +  " \n "
        hello!.text = hello!.text! +  "כאן נמצאות ההגדרות שלך"

        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "infoHasChanged", object: nil))

        /*classAndLayerInput?.endEditing(true)
        classNum?.endEditing(true)
        layerNum?.endEditing(true)*/
    }

    @IBAction func updateClassandLayer(sender: UITextField){
        NSUserDefaults.standardUserDefaults().setValue(classAndLayerInput!.selectedRowInComponent(0) + 1, forKey: "classNum")
        //NSUbiquitousKeyValueStore.defaultStore().setValue(sender.text, forKey: "classNum")
        NSUserDefaults.standardUserDefaults().synchronize()
        //NSUbiquitousKeyValueStore.defaultStore().synchronize()

        NSUserDefaults.standardUserDefaults().setValue(oppositeLayers[layerNum!.text], forKey: "layerNum")
        //NSUbiquitousKeyValueStore.defaultStore().setValue(sender.text, forKey: "layerNum")
        NSUserDefaults.standardUserDefaults().synchronize()
        //NSUbiquitousKeyValueStore.defaultStore().synchronize()
        /*classAndLayerInput?.endEditing(true)
        classNum?.endEditing(true)
        layerNum?.endEditing(true)*/

        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "infoHasChanged", object: nil))
        self.hideKeyboard()
    }

    @IBAction func beginUserLogin(sender: UITextField){
        if (userName?.text.isEmpty == true || password?.text.isEmpty == true) {
            if (objc_getClass("UIAlertController") != nil) {
                let emptyAlert = UIAlertController(title: "פרטים חסרים", message: "אנא וודא כי מילאת שם משתמש וסיסמה", preferredStyle: UIAlertControllerStyle.Alert)
                emptyAlert.addAction(UIAlertAction(title: "הבנתי", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    
                }))
                self.presentViewController(emptyAlert, animated: true, completion: { () -> Void in
                    
                })
            } else {
                let emptyAlert = UIAlertView(title: "פרטים חסרים", message: "אנא וודא כי מילאת שם משתמש וסיסמה", delegate: nil, cancelButtonTitle: "הבנתי")
                emptyAlert.show()
            }
        } else {
            //Begin connecting user asynchronously
            request(.POST, "http://ohel-shem.com/~royejacobovich/iPhoneApp/login.php", parameters: ["username" : userName!.text, "password" : password!.text], encoding: ParameterEncoding.URL)
                .response { (request, response, data, error) in
                    println(request)
                    println(response)
                    println(error)
                    if (error == nil && response?.statusCode != 403 && response?.statusCode == 200){
                        //Save username and password
                        NSUserDefaults.standardUserDefaults().setValue(self.userName!.text, forKey: "username")
                        NSUserDefaults.standardUserDefaults().setValue(self.password!.text, forKey: "password")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        print(data)
                    }
                    if (error != nil){
                        print(error)
                    }
            }
        }
    }
}