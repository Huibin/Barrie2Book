//
//  BookInfoViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-23.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class BookInfoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var authorText: UITextField!
    @IBOutlet weak var editionText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var degreeSlider: UISlider!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var user: String!
    var currentType: String = "1"
    var addTask: NSURLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateUI() {
        if currentType == "1" {
            priceText.hidden = false
            degreeLabel.hidden = false
            degreeSlider.hidden = false
        } else {
            priceText.hidden = true
            degreeLabel.hidden = true
            degreeSlider.hidden = true
        }
    }
    
    func showAlert(messageStr: String) {
        let alert = UIAlertController(title: "Warning!", message: messageStr,preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeSearchType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentType = "1"
            updateUI()
        case 1:
            currentType = "0"
            updateUI()
        default:
            return
        }
    }
    
    @IBAction func sliderMoved(sender: UISlider) {
        let sliderValue = lroundf(degreeSlider.value)
        degreeLabel.text = "\(sliderValue)% new"

    }
    
    
    func performAddBook() {
        //validate input
        if !Validation.isValidInput(titleText.text) || !Validation.isValidInput(authorText.text) || !Validation.isValidInput(editionText.text) {
            showAlert("Book title, author, or edition is valid.")
            return
        }
        if currentType == "1" && !Validation.isValidInput(priceText.text) {
            showAlert("Please give this book a price.")
            return
        }
        //UI
        titleText.enabled = false
        authorText.enabled = false
        editionText.enabled = false
        priceText.enabled = false
        degreeSlider.enabled = false
        degreeLabel.enabled = false
        spinner?.startAnimating()
        //add book
        addTask?.cancel()
        var url: NSURL!
        if currentType == "1" {
            url = Searcher.urlWithSellBookText("", titleText.text, authorText.text, "\(editionText.text)", "", "", user, "\(lroundf(degreeSlider.value))", priceText.text, 0)
        } else if currentType == "0" {
            url = Searcher.urlWithNeedBookText("", titleText.text, authorText.text, "\(editionText.text)", "", "", user, 0)
        }
        let session = NSURLSession.sharedSession()
        addTask = session.dataTaskWithURL(url, completionHandler: {
            data, response, error in
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
                            self.spinner?.stopAnimating()
                            let hudView = HudView.hudInView(self.view, animated: true)
                            hudView.text = "Done"
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC))),
                                dispatch_get_main_queue()) {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        case "exist":
                            self.spinner?.stopAnimating()
                            self.titleText.enabled = true
                            self.authorText.enabled = true
                            self.editionText.enabled = true
                            self.priceText.enabled = true
                            self.degreeSlider.enabled = true
                            self.degreeLabel.enabled = true
                            self.showAlert("Book is alread exist.")
                        default:
                            self.spinner?.stopAnimating()
                            self.titleText.enabled = true
                            self.authorText.enabled = true
                            self.editionText.enabled = true
                            self.priceText.enabled = true
                            self.degreeSlider.enabled = true
                            self.degreeLabel.enabled = true
                            self.showAlert("Network error, please try later.")
                        }
                    }
                    return
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.spinner?.stopAnimating()
                self.titleText.enabled = true
                self.authorText.enabled = true
                self.editionText.enabled = true
                self.priceText.enabled = true
                self.degreeSlider.enabled = true
                self.degreeLabel.enabled = true
                self.showAlert("Network error, please try later.")
            }
        })
        addTask?.resume()

    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    @IBAction func backToAddCenter(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func finishAddBook(sender: UIBarButtonItem) {
        performAddBook()
    }
    
    //textfield done
    func textFieldShouldReturn(textField: UITextField) {
        textField.resignFirstResponder()
        performAddBook()
    }

}
