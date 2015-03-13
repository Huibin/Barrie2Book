//
//  Validation.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-11.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import Foundation


class Validation {
    
    var username: String!
    var password: String!
    
    //validate email address
    class func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        if let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx) {
            return emailTest.evaluateWithObject(email)
        }
        return false
    }
    
    //validate password format
    func isValidPassword(password: String) -> Bool {
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        let range = password.rangeOfCharacterFromSet(whitespace)
        if let test = range {
            return false
        }
        else {
            if countElements(password) < 6 {
                return false
            } else {
                return true
            }
        }
    }
    
    //validate two password 
    func isSamePassword(pwd1: String, pwd2: String) -> Bool {
        return pwd1 == pwd2 ? true: false
    }
    
    
    //return sign up url: exist, ok, fail
    class func urlWithSignUpText(username: String, _ password: String) -> NSURL {
        let urlString = "http://mycodeleaf.com/BookFinder/signup.php?name=\(username)&password=\(password)"
        let url = NSURL(string: urlString)
        return url!
    }

    //return log in url: empty, ok, fail
    class func urlWithLoginText(username: String, _ password: String) -> NSURL {
        let urlString = "http://mycodeleaf.com/BookFinder/login.php?name=\(username)&password=\(password)"
        let url = NSURL(string: urlString)
        return url!
    }
    
    //return remind password url: empty, ok, fail
    class func urlWithRemindText(username: String) -> NSURL {
        let urlString = "http://mycodeleaf.com/BookFinder/remind.php?name=\(username)"
        let url = NSURL(string: urlString)
        return url!
    }
    
    //return change password url: ok, fail
    class func urlWithChangePassword(username: String, _ newPassword: String) -> NSURL {
        let urlString = "http://mycodeleaf.com/BookFinder/change.php?name=\(username)&password=\(newPassword)"
        let url = NSURL(string: urlString)
        return url!
    }
    
    
}