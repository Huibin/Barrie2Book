//
//  UserCenterViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-12.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class UserCenterViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var booksLabel: UILabel!
    
    var user: Owners! {
        didSet {
            logTag != logTag
        }
    }
    var logTag: Bool = true {
        didSet {
            tableView.reloadData()
        }
    };
    
//    struct TableViewCellIdentifiers {
//        static let SignupLoginCell = "SignupLoginCell"
//        static let LoginCell = "LoginCell"
//        static let BooksCell = "BooksCell"
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //custom tint color in tableview controller
        tableView.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) {
        textField.resignFirstResponder()
    }

    //pop alert from center
    func showGeneralAlert(titleStr: String, _ messageStr: String) {
        let alert = UIAlertController(title: titleStr, message: messageStr,preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //pop log out alert
    func showLogoutAlert() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle:.ActionSheet)
        let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive, handler: { action in
            self.logTag = false
        })
        controller.addAction(logoutAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        controller.addAction(cancelAction)
        presentViewController(controller, animated: true, completion: nil)
    }
    
// MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && logTag == true {
            return 1
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        //custom selected cell color
        let selectedView = UIView(frame: CGRect.zeroRect)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        cell.selectedBackgroundView = selectedView
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let imageName = logTag ? "login" : "unlog"
            cell.imageView?.image = UIImage(named: imageName)
            loginLabel.text = logTag ? "username" : "unkown user"
            loginLabel.textColor = logTag ? UIColor.blackColor(): UIColor.lightGrayColor()
        } else if indexPath.section == 1 {
            cell.imageView?.image = UIImage(named: "history")
            booksLabel.text = "manage your own books"
            booksLabel.textColor = logTag ? UIColor.blackColor(): UIColor.lightGrayColor()
        }
        
        return cell

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            showLogoutAlert()
        } else if indexPath.section == 1 {
            performSegueWithIdentifier("ShowBookCenter", sender: tableView)
        }
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (indexPath.section == 0 && indexPath.row == 0 && logTag == false) || (indexPath.section == 1 && logTag == false) {
            return nil
        } else {
            return indexPath
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    //user validation
    func userValidation() {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
