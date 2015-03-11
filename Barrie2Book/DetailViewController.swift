//
//  DetailViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-10.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    
    @IBOutlet weak var conditionTitleLabel: UILabel!
    @IBOutlet weak var conditionValueLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var book: Books!
    var downloadTask: NSURLSessionDownloadTask?
    
    //initial for pop up transit
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    //stop download task for book cover image
    deinit {
        downloadTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //custom background color
        view.backgroundColor = UIColor.clearColor()
        //custom popup view color
        view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        //custom popup view corner sharp
        popupView.layer.cornerRadius = 10

        //display book information
        if book != nil {
            updateUI()
        }
        
        //close popup view
        let gestureRecognizer = UITapGestureRecognizer(target: self,
            action: Selector("closeDetailView"))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //load cover image
    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL(url, completionHandler: {
            [weak self] url, response, error in
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url) {
                    if let image = UIImage(data: data) {
                        dispatch_async(dispatch_get_main_queue()) {
                            if let strongSelf = self {
                                strongSelf.coverImage.image = image
                            }
                        }
                    }
                }
            }
        })
        downloadTask.resume()
        return downloadTask
    }

    //display book information
    func updateUI() {
        if let imageUrl = book.imageUrl {
            if let url = NSURL(string: imageUrl) {
                downloadTask = loadImageWithURL(url)
            }
        } else {
            coverImage.image = UIImage(named: "Placeholder")
            }
        titleLabel.text = book.title
        authorLabel.text = book.author
        editionLabel.text = book.edition
        if let condition = book.degree {
            conditionValueLabel.text = book.degree
        } else {
            conditionTitleLabel.text = ""
            conditionValueLabel.text = ""
        }
        if let bookPrice = book.price {
            priceButton.setTitle("$ \(bookPrice)", forState: .Normal)
        } else {
            priceButton.setTitle("tell me", forState: .Normal)
        }
    }
    
    //send email
    @IBAction func sendEmail(sender: UIButton) {
        let title = "exchange book '\(book.title)'".stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let email = "\(book.owner)?&subject=\(title)"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    //close popup view
    func closeDetailView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //animate popup window appear
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    //animate popup window disappear
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideOutAnimationController()
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


extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    //use vitual controller
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return SlideOutAnimationController()
//    }
}


extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === view)
    }
}