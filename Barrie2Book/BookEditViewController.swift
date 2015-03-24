//
//  BookEditViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-16.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

protocol BookEditViewControllerDelegate: class {
    func didEditing(controller: BookEditViewController)
}

class BookEditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var authorText: UITextField!
    @IBOutlet weak var editionText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var degreeSlider: UISlider!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var spinner: NSLayoutConstraint!
    @IBOutlet weak var activeSpinner: UIActivityIndicatorView!
    
    var user: String!
    var type: String!
    var deleteBook: Books!
    
    weak var delegate: BookEditViewControllerDelegate?
    
    var deleteTask: NSURLSessionDataTask?
    var deleteStatus = 0
    var addTask: NSURLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderMoved(sender: UISlider) {
        let sliderValue = lroundf(degreeSlider.value)
        degreeLabel.text = "\(sliderValue)% new"
    }

    func updateUI() {
        if let book = deleteBook {
            authorText.text = book.author
            titleText.text = book.title
            editionText.text = book.edition == nil ? "" : book.edition
            if type == "0" {
                priceText.hidden = true
                degreeSlider.hidden = true
                degreeLabel.hidden = true
            } else {
                priceText.text = book.price
                degreeLabel.text = book.degree
                let sep = NSCharacterSet(charactersInString: "%")
                let slideValue = book.degree.componentsSeparatedByCharactersInSet(sep)[0].toInt()!
                degreeSlider.value = Float(slideValue)
            }
        } else if type == "0" {
            priceText.hidden = true
            degreeSlider.hidden = true
            degreeLabel.hidden = true
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
    
    func performEditBook() {
        //validate input
        if !Validation.isValidInput(titleText.text) || !Validation.isValidInput(authorText.text) || !Validation.isValidInput(editionText.text) {
            showAlert("Book title, author, or edition is valid.")
            return
        }
        //UI
        titleText.enabled = false
        authorText.enabled = false
        editionText.enabled = false
        priceText.enabled = false
        degreeSlider.enabled = false
        degreeLabel.enabled = false
        activeSpinner?.startAnimating()
        //delete book
        if let book = deleteBook {
            deleteTask?.cancel()
            var url: NSURL!
            if type == "1" {
                let sep = NSCharacterSet(charactersInString: "%")
                let degree = book.degree.componentsSeparatedByCharactersInSet(sep)[0]
                url = Searcher.urlWithSellBookText("", book.title, book.author, book.edition, "", "", user, degree, book.price, 1)
            } else if type == "0" {
                url = Searcher.urlWithNeedBookText("", book.title, book.author, book.edition, "", "", book.owner, 1)
            }
            let session = NSURLSession.sharedSession()
            deleteTask = session.dataTaskWithURL(url, completionHandler: {
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
                                self.deleteStatus = 1
                            default:
                                self.activeSpinner?.stopAnimating()
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
                    self.activeSpinner?.stopAnimating()
                    self.titleText.enabled = true
                    self.authorText.enabled = true
                    self.editionText.enabled = true
                    self.priceText.enabled = true
                    self.degreeSlider.enabled = true
                    self.degreeLabel.enabled = true
                    self.showAlert("Network error, please try later.")
                }
            })
            deleteTask?.resume()
        }
        //add book
            addTask?.cancel()
            var url: NSURL!
            if type == "1" {
                url = Searcher.urlWithSellBookText(deleteBook.ISBN, titleText.text, authorText.text, "\(editionText.text)", "", deleteBook.imageUrl, user, "\(lroundf(degreeSlider.value))", priceText.text, 0)
            } else if type == "0" {
                url = Searcher.urlWithNeedBookText(deleteBook.ISBN, titleText.text, authorText.text, "\(editionText.text)", "", deleteBook.imageUrl, user, 0)
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
                                self.activeSpinner?.stopAnimating()
                                self.delegate?.didEditing(self)
                                let hudView = HudView.hudInView(self.view, animated: true)
                                hudView.text = "Done"
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC))),
                                    dispatch_get_main_queue()) {
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                }
                            case "exist":
                                self.activeSpinner?.stopAnimating()
                                self.titleText.enabled = true
                                self.authorText.enabled = true
                                self.editionText.enabled = true
                                self.priceText.enabled = true
                                self.degreeSlider.enabled = true
                                self.degreeLabel.enabled = true
                                self.showAlert("Book is alread exist.")
                            default:
                                self.activeSpinner?.stopAnimating()
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
                    self.activeSpinner?.stopAnimating()
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
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//
//    }

    @IBAction func getBackToBookCenter(sender: UIBarButtonItem) {
        deleteTask?.cancel()
        addTask?.cancel()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func finishEditBook(sender: UIBarButtonItem) {
        performEditBook()
    }

    //textfield done
    func textFieldShouldReturn(textField: UITextField) {
        textField.resignFirstResponder()
        performEditBook()
    }
    
}
