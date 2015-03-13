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
    

    @IBAction func finishInput(sender: UITextField) {
        sender.resignFirstResponder()
        println("end")
    }
    
    @IBAction func login(sender: UIButton) {
        println("login")
    }
    
    @IBAction func remind(sender: UIButton) {
        println("remind")
    }

    @IBAction func signup(sender: UIButton) {
        println("signup")
    }
    
    func performValidation() {
        
    }
}
