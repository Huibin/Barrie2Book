//
//  UserValidationViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-14.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

protocol UserValidationViewControllerDelegate: class {
    func didValidation(controller: UserValidationViewController, _ user: String)
}

class UserValidationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var type: String!
    struct ValidateType {
        static let login = "Log In"
        static let signup = "Sign Up"
        static let remind = "Email Password"
        static let change = "Change Password"
    }
    
    var validationTask: NSURLSessionDataTask?
    var user: String? {
        didSet {
            spinner?.stopAnimating()
        }
    }
    weak var delegate: UserValidationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //custom tint color
        view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        
        updateUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelValidation(sender: UIBarButtonItem) {
        validationTask?.cancel()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func performValidation() {
        if !Validation.isValidEmail(usernameText.text) {
            showAlert("Please input valid email address.")
            return
        }
        if let validateType = type {
            switch validateType {
            case ValidateType.login:
                performLogin()
            case ValidateType.signup:
                performSignup()
            case ValidateType.remind:
                performRemind()
            case ValidateType.change:
                performChangePassword()
            default:
                return
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) {
        textField.resignFirstResponder()
        performValidation()
    }

//MARK: - Validate Function
    func performLogin() {
        if !Validation.isValidPassword(passwordText.text) {
            showAlert("Legnth of password should be more than 6 characters without space.")
            return
        }
        validationTask?.cancel()
        usernameText.enabled = false
        passwordText.enabled = false
        actionButton.enabled = false
        spinner?.startAnimating()
        let loginUrl = Validation.urlWithLoginText(usernameText.text, passwordText.text)
        let session = NSURLSession.sharedSession()
        validationTask = session.dataTaskWithURL(loginUrl, completionHandler: { data, response, error in
            if let error = error {
                if error.code == -999 {
                    return
                }
            }
            if let httpRes = response as? NSHTTPURLResponse {
                if httpRes.statusCode == 200 {
                    let resultStr = NSString(data: data, encoding: NSUTF8StringEncoding)!
                    dispatch_async(dispatch_get_main_queue()) {
                        switch resultStr {
                        case "empty":
                            self.showAlert("User is not exist.")
                            self.usernameText.enabled = true
                            self.passwordText.enabled = true
                            self.actionButton.enabled = true
                            self.spinner?.stopAnimating()
                        case "ok":
                            self.user = self.usernameText.text
                            let hudView = HudView.hudInView(self.view, animated: true)
                            hudView.text = "Done"
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC))),
                                dispatch_get_main_queue()) {
                                    self.delegate?.didValidation(self, self.user!)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        default:
                            self.showAlert("Network error, please try later.")
                            self.usernameText.enabled = true
                            self.passwordText.enabled = true
                            self.actionButton.enabled = true
                            self.spinner?.stopAnimating()
                        }
                    }
                    return
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.showAlert("Network error, please try later.")
            }
        })
        validationTask?.resume()
    }
    
    func performSignup() {
        if !Validation.isValidPassword(passwordText.text) {
            showAlert("Legnth of password should be more than 6 characters without space.")
            return
        }
        validationTask?.cancel()
        usernameText.enabled = false
        passwordText.enabled = false
        actionButton.enabled = false
        spinner?.startAnimating()
        let loginUrl = Validation.urlWithSignUpText(usernameText.text, passwordText.text)
        let session = NSURLSession.sharedSession()
        validationTask = session.dataTaskWithURL(loginUrl, completionHandler: { data, response, error in
            if let error = error {
                if error.code == -999 {
                    return
                }
            }
            if let httpRes = response as? NSHTTPURLResponse {
                if httpRes.statusCode == 200 {
                    let resultStr = NSString(data: data, encoding: NSUTF8StringEncoding)!
                    dispatch_async(dispatch_get_main_queue()) {
                        switch resultStr {
                        case "exist":
                            self.showAlert("User is exist.")
                            self.usernameText.enabled = true
                            self.passwordText.enabled = true
                            self.actionButton.enabled = true
                            self.spinner?.stopAnimating()
                        case "ok":
                            self.user = self.usernameText.text
                            let hudView = HudView.hudInView(self.view, animated: true)
                            hudView.text = "Done"
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC))),
                                dispatch_get_main_queue()) {
                                    self.delegate?.didValidation(self, self.user!)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        default:
                            self.showAlert("Network error, please try later.")
                            self.usernameText.enabled = true
                            self.passwordText.enabled = true
                            self.actionButton.enabled = true
                            self.spinner?.stopAnimating()
                        }
                    }
                    return
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.showAlert("Network error, please try later.")
            }
        })
        validationTask?.resume()
    }
    

    func performRemind() {
        validationTask?.cancel()
        usernameText.enabled = false
        passwordText.enabled = false
        actionButton.enabled = false
        spinner?.startAnimating()
        let loginUrl = Validation.urlWithRemindText(usernameText.text)
        let session = NSURLSession.sharedSession()
        validationTask = session.dataTaskWithURL(loginUrl, completionHandler: { data, response, error in
            if let error = error {
                if error.code == -999 {
                    return
                }
            }
            if let httpRes = response as? NSHTTPURLResponse {
                if httpRes.statusCode == 200 {
                    let resultStr = NSString(data: data, encoding: NSUTF8StringEncoding)!
                    dispatch_async(dispatch_get_main_queue()) {
                        switch resultStr {
                        case "empty":
                            self.showAlert("User is not exist.")
                            self.usernameText.enabled = true
                            self.passwordText.enabled = true
                            self.actionButton.enabled = true
                            self.spinner?.stopAnimating()
                        case "ok":
                            let hudView = HudView.hudInView(self.view, animated: true)
                            hudView.text = "Done"
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC))),
                                dispatch_get_main_queue()) {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        default:
                            self.showAlert("Network error, please try later.")
                            self.usernameText.enabled = true
                            self.passwordText.enabled = true
                            self.actionButton.enabled = true
                            self.spinner?.stopAnimating()
                        }
                    }
                    return
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.showAlert("Network error, please try later.")
            }
        })
        validationTask?.resume()
    }

    func performChangePassword() {
        if !Validation.isValidPassword(passwordText.text) {
            showAlert("Legnth of password should be more than 6 characters without space.")
            return
        }
        validationTask?.cancel()
        usernameText.enabled = false
        passwordText.enabled = false
        actionButton.enabled = false
        spinner?.startAnimating()
        let loginUrl = Validation.urlWithChangePassword(usernameText.text, passwordText.text)
        let session = NSURLSession.sharedSession()
        validationTask = session.dataTaskWithURL(loginUrl, completionHandler: { data, response, error in
            if let error = error {
                if error.code == -999 {
                    return
                }
            }
            if let httpRes = response as? NSHTTPURLResponse {
                if httpRes.statusCode == 200 {
                    let resultStr = NSString(data: data, encoding: NSUTF8StringEncoding)!
                    dispatch_async(dispatch_get_main_queue()) {
                        switch resultStr {
                        case "ok":
                            let hudView = HudView.hudInView(self.view, animated: true)
                            hudView.text = "Done"
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC))),
                                dispatch_get_main_queue()) {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        default:
                            self.showAlert("Network error, please try later.")
                            self.usernameText.enabled = true
                            self.passwordText.enabled = true
                            self.actionButton.enabled = true
                            self.spinner?.stopAnimating()
                        }
                    }
                    return
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.showAlert("Network error, please try later.")
            }
        })
        validationTask?.resume()
    }
    
//MARK: - UI Function
    func updateUI(){
        if let validateType = type {
            switch validateType {
            case ValidateType.login, ValidateType.signup:
                actionButton.setTitle(validateType, forState: .Normal)
                usernameText.becomeFirstResponder()
            case ValidateType.remind:
                actionButton.setTitle(validateType, forState: .Normal)
                usernameText.becomeFirstResponder()
                passwordText.hidden = true
            case ValidateType.change:
                actionButton.setTitle(validateType, forState: .Normal)
                passwordText.becomeFirstResponder()
                usernameText.text = user!
            default:
                return
            }
        }
    }
    
    //pop up alert
    func showAlert(messageStr: String) {
        let alert = UIAlertController(title: "Warning!", message: messageStr,preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
