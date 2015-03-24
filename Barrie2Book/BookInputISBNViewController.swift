//
//  BookInputISBNViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-23.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class BookInputISBNViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var authorText: UITextField!
    @IBOutlet weak var editionText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var degreeSlider: UISlider!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var ISBNText: UITextField!
    
    var user: String!
    var currentType = "1"
    
    var book: Books!
    var searchFinish = 0
    var barcode: String!
    var searchTask: NSURLSessionDataTask?
    var downloadTask: NSURLSessionDownloadTask?
    var addTask: NSURLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UI
    func updateUI() {
        if searchFinish == 0 {
            ISBNText.hidden = false
            coverImage.hidden = true
            titleText.hidden = true
            authorText.hidden = true
            editionText.hidden = true
            priceText.hidden = true
            degreeSlider.hidden = true
            degreeLabel.hidden = true
            spinner.stopAnimating()
        } else {
            coverImage.hidden = false
            if let imageUrl = book.imageUrl {
                if let url = NSURL(string: imageUrl) {
                    downloadTask = loadImageWithURL(url)
                }
            } else {
                coverImage.image = UIImage(named: "Placeholder")
            }
            titleText.hidden = false
            titleText.text = book.title
            titleText.enabled = false
            authorText.hidden = false
            authorText.text = book.author
            authorText.enabled = false
            editionText.hidden = false
            editionText.text = book.edition
            editionText.enabled = false
            ISBNText.hidden = true
            ISBNText.resignFirstResponder()
            if currentType == "1" {
                priceText.hidden = false
                degreeSlider.hidden = false
                degreeLabel.hidden = false
            } else {
                priceText.hidden = true
                degreeSlider.hidden = true
                degreeLabel.hidden = true
            }
            spinner.stopAnimating()
        }
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
    
    func showAlert(messageStr: String) {
        let alert = UIAlertController(title: "Warning!", message: messageStr,preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
//MARK: - Function
    //get book information
    func performSearch() {
        //validate input
        if !Validation.isValidISBN(ISBNText.text) {
            showAlert("Please input valid ISBN.")
            return
        } else {
            self.barcode = ISBNText.text
        }
        searchTask?.cancel()
        spinner?.startAnimating()
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(barcode)"
        let url = NSURL(string: urlString)!
        let session = NSURLSession.sharedSession()
        searchTask = session.dataTaskWithURL(url, completionHandler: {
            data, response, error in
            if let error = error {
                if error.code == -999 {
                    return
                }
            }
            if let httpRes = response as? NSHTTPURLResponse {
                if httpRes.statusCode == 200 {
                    if let jsonData = Searcher.parseJSON(data) {
                        if let jsonDic = Searcher.parseGoogleAPI(jsonData) {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.book = jsonDic
                                self.searchFinish = 1
                                self.updateUI()
                            }
                            return
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.showAlert("Network error, please try later.")
                                self.spinner?.stopAnimating()
                            }
                            return
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.showAlert("Network error, please try later.")
                self.spinner?.stopAnimating()
            }
        })
        searchTask?.resume()
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
    
    //add book
    func performAddBook() {
        //validate input
        if currentType == "1" && !Validation.isValidInput(priceText.text) {
            showAlert("Please give this book a price.")
            return
        }
        //UI
        priceText.enabled = false
        degreeSlider.enabled = false
        degreeLabel.enabled = false
        spinner?.startAnimating()
        //add book
        addTask?.cancel()
        var url: NSURL!
        if currentType == "1" {
            url = Searcher.urlWithSellBookText(barcode, book.title, book.author, book.edition, "", book.imageUrl, user, "\(lroundf(degreeSlider.value))", priceText.text, 0)
        } else if currentType == "0" {
            url = Searcher.urlWithNeedBookText(barcode, titleText.text, book.author, book.edition, "", book.imageUrl, user, 0)
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
                            self.priceText.enabled = true
                            self.degreeSlider.enabled = true
                            self.degreeLabel.enabled = true
                            self.showAlert("Book is alread exist.")
                        default:
                            self.spinner?.stopAnimating()
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
        if searchFinish == 0 {
            performSearch()
        } else if searchFinish == 1 {
            performAddBook()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) {
        textField.resignFirstResponder()
        if searchFinish == 0 {
            performSearch()
        } else if searchFinish == 1 {
            performAddBook()
        }
    }
}
