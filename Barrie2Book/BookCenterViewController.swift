//
//  BookCenterViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-12.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class BookCenterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    struct TableViewCellIdentifiers {
        static let loadingCell = "LoadingCell"
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    var currentType = "1"
    
    var user: String!
    var books: [Books] = [Books]() {
        didSet {
            tableView.reloadData()
        }
    }
    var editBook: Books!
    
    var searchTask: NSURLSessionDataTask?
    var deleteTask: NSURLSessionDataTask?
    var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //table style
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        //register table cell
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)

        reloadBooks(currentType, user)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //pop information alert
    func showAlert(titleStr: String, _ messageStr: String) {
        let alert = UIAlertController(title: titleStr, message: messageStr,preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //pop action alert
    func showClickAlert() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle:.ActionSheet)
        controller.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
        let editBookAction = UIAlertAction(title: "Edit Book", style: .Default, handler: { action in
            self.performSegueWithIdentifier("ShowEditBook", sender: self)
        })
        controller.addAction(editBookAction)
        let deleteAction = UIAlertAction(title: "Finish Exchange", style: .Destructive, handler: { action in
            let alert = UIAlertController(title: "Warning", message: "Are you sure to delete book?",preferredStyle: .Alert)
            alert.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
            let actionOK = UIAlertAction(title: "OK", style: .Default, handler: {action in self.deleteBooks()})
            alert.addAction(actionOK)
            let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alert.addAction(actionCancel)
            self.presentViewController(alert, animated: true, completion: nil)
        })
        controller.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        controller.addAction(cancelAction)
        presentViewController(controller, animated: true, completion: nil)
    }
    
//MARK: - Manage Function
    //reload data
    func reloadBooks(type: String, _ user: String) {
        searchTask?.cancel()
        isLoading = true
        books.removeAll()
        
        let url = Searcher.urlWithShowText(type, user)
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
                        if let jsonDic = Searcher.parseDictionary(jsonData) {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.books = jsonDic
                                self.isLoading = false
                            }
                            return
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.books = [Books]()
                                self.isLoading = false
                            }
                            return
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.isLoading = false
                self.books = [Books]()
                self.showAlert("Sorry", "Network error, please try later.")
            }
        })
        searchTask?.resume()
    }

    @IBAction func changeSearchType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentType = "1"
            reloadBooks(currentType, user)
        case 1:
            currentType = "0"
            reloadBooks(currentType, user)
        default:
            return
        }
    }
    
    
    //delete book
    func deleteBooks() {
        deleteTask?.cancel()
        isLoading = true
        
        var url: NSURL!
        if (currentType == "1") {
            let sep = NSCharacterSet(charactersInString: "%")
            let degree = editBook.degree.componentsSeparatedByCharactersInSet(sep)[0]
            url = Searcher.urlWithSellBookText("", editBook.title, editBook.author, editBook.edition, "", "", editBook.owner, degree, editBook.price, 1)
        } else if (currentType == "0") {
            url = Searcher.urlWithNeedBookText("", editBook.title, editBook.author, editBook.edition, "", "", editBook.owner, 1)
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
                            self.reloadBooks(self.currentType, self.user)
                        default:
                            self.showAlert("Warning", "Network error, please try later.")
                        }
                    }
                    return
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.showAlert("Warning", "Network error, please try later.")
            }
        })
        deleteTask?.resume()

    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "ShowEditBook":
                    let navigationController = segue.destinationViewController as UINavigationController
                    let controller = navigationController.topViewController as BookEditViewController
                    controller.user = user
                    controller.type = currentType
                    controller.deleteBook = editBook
                    controller.delegate = self
                case "ShowAddBook":
                    let navigationController = segue.destinationViewController as UINavigationController
                    let controller = navigationController.topViewController as AddBookCenterController
                    controller.user = user
                    controller.delegate = self
                default:
                    return
            }
        }
    }

    @IBAction func getBackToUserCenter(sender: UIBarButtonItem) {
        searchTask?.cancel()
        dismissViewControllerAnimated(true, completion: nil)
    }

    
}

//MARK: - Table Data
extension BookCenterViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count == 0 ? 1: books.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as UITableViewCell
            let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if books.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
            
            let book = books[indexPath.row]
            cell.cellConfigue(book)
            return cell
        }
    }
    
    //swap delete
    func tableView(tableView: UITableView, commitEditingStyle editingStyle:
        UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            editBook = books[indexPath.row]
            let alert = UIAlertController(title: "Warning", message: "Are you sure to delete book?" ,preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: {action in self.deleteBooks()})
            alert.view.tintColor = UIColor(red: 103/255, green: 153/255, blue: 170/255, alpha: 1)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}

//MARK: - Table Delegate
extension BookCenterViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        editBook = books[indexPath.row]
        showClickAlert()
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if isLoading || books.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}


extension BookCenterViewController: BookEditViewControllerDelegate {
    func didEditing(controller: BookEditViewController) {
        reloadBooks(currentType, user)
    }
}


extension BookCenterViewController: AddBookCenterControllerDelegate {
    func didAdding(controller: AddBookCenterController) {
        reloadBooks(currentType, user)
    }
}