//
//  UserCenterViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-12.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class UserCenterViewController: UITableViewController {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var booksLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var remindButton: UIButton!
    
    var owner: String! {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("username")
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "username")
            NSUserDefaults.standardUserDefaults().synchronize()
            logTag = true
        }
    }
    var logTag: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //custom tint color in tableview controller
        tableView.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        
        logTag = owner != nil ? true: false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//MARK: - Alert
    //pop alert from center
    func showGeneralAlert(titleStr: String, _ messageStr: String) {
        let alert = UIAlertController(title: titleStr, message: messageStr,preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //pop log out alert
    func showLogoutAlert() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle:.ActionSheet)
        controller.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        let changepasswordAction = UIAlertAction(title: "Change Password", style: .Default, handler: { action in
            self.performSegueWithIdentifier("ShowChange", sender: self)
        })
        controller.addAction(changepasswordAction)
        let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive, handler: { action in
            self.owner = nil
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
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let imageName = logTag ? "login" : "unlog"
            cell.imageView?.image = UIImage(named: imageName)
            loginLabel.text = logTag ? owner : "unkown user"
            loginLabel.textColor = logTag ? UIColor.blackColor(): UIColor.lightGrayColor()
            let selectedView = UIView(frame: CGRect.zeroRect)
            selectedView.backgroundColor = logTag ? UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5) : UIColor.whiteColor()
            cell.selectedBackgroundView =  selectedView
        } else if indexPath.section == 1 {
            cell.imageView?.image = UIImage(named: "history")
            booksLabel.text = "manage books"
            booksLabel.textColor = logTag ? UIColor.blackColor(): UIColor.lightGrayColor()
            let selectedView = UIView(frame: CGRect.zeroRect)
            selectedView.backgroundColor = logTag ? UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5) : UIColor.whiteColor()
            cell.selectedBackgroundView =  selectedView
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
        if (indexPath.section == 0 && indexPath.row == 0 && logTag == true) || (indexPath.section == 1 && logTag == true) {
            return indexPath
        } else {
            return nil
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

// MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "ShowLogin":
                    let navigationController = segue.destinationViewController as UINavigationController
                    let controller = navigationController.topViewController as UserValidationViewController
                    controller.delegate = self
                    controller.type = "Log In"
                case "ShowSignup":
                    let navigationController = segue.destinationViewController as UINavigationController
                    let controller = navigationController.topViewController as UserValidationViewController
                    controller.delegate = self
                    controller.type = "Sign Up"
                case "ShowRemind":
                    let navigationController = segue.destinationViewController as UINavigationController
                    let controller = navigationController.topViewController as UserValidationViewController
                    controller.delegate = self
                    controller.type = "Email Password"
                case "ShowChange":
                    let navigationController = segue.destinationViewController as UINavigationController
                    let controller = navigationController.topViewController as UserValidationViewController
                    controller.delegate = self
                    controller.type = "Change Password"
                    controller.user = owner
                case "ShowBookCenter":
                    let navigationController = segue.destinationViewController as UINavigationController
                    let controller = navigationController.topViewController as BookCenterViewController
                    controller.user = owner
                default:
                    return
            }
        }
    }

}


extension UserCenterViewController: UserValidationViewControllerDelegate {
    func didValidation(controller: UserValidationViewController, _ user: String) {
        owner = user
    }
}
