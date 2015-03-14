//
//  SignupLoginCell.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-13.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class SignupLoginCell: UITableViewCell {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var remindButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    struct ErrorType {
        static let emailformat = 0
        static let LoginCell = "LoginCell"
        static let BooksCell = "BooksCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.endEditing(true)
    }


    
    @IBAction func login(sender: UIButton) {
        println(username.text)
        username.resignFirstResponder()
    }
    
    @IBAction func remind(sender: UIButton) {
        println("remind")
    }

    @IBAction func signup(sender: UIButton) {
        println("signup")
    }
    
 
}
