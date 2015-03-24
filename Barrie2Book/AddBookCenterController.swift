//
//  AddBookCenterController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-23.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

protocol AddBookCenterControllerDelegate: class {
    func didAdding(controller: AddBookCenterController)
}

class AddBookCenterController: UIViewController {

    var user: String!
    weak var delegate: AddBookCenterControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowScanISBN":
                let navigationController = segue.destinationViewController as UINavigationController
                let controller = navigationController.topViewController as BookISBNViewController
                controller.user = user
            case "ShowInputISBN":
                let navigationController = segue.destinationViewController as UINavigationController
                let controller = navigationController.topViewController as BookInputISBNViewController
                controller.user = user
            case "ShowInputInfo":
                let navigationController = segue.destinationViewController as UINavigationController
                let controller = navigationController.topViewController as BookInfoViewController
                controller.user = user
            default:
                return
            }
        }
    }

    //cancel to back
    
    @IBAction func backToBookCenter(sender: UIBarButtonItem) {
        delegate?.didAdding(self)
        dismissViewControllerAnimated(true, completion: nil)
    }

}
