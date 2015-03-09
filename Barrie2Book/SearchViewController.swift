//
//  SearchViewController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-04.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    struct TableViewCellIdentifiers {
        static let loadingCell = "LoadingCell"
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    let searcher: Searcher!
    var isLoading: Bool = false
    
    var books: [Books] = [Books]() {
        didSet {
            searchTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //table style
        searchTableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        searchTableView.rowHeight = 80
        //register table cell
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        searchTableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        searchTableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        searchTableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)

        reloadBooks("", "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //pop alert to show error
    func showAlert(titleStr: String, _ messageStr: String) {
        let alert = UIAlertController(title: titleStr, message: messageStr,preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //reload data
    func reloadBooks(title: String, _ type: String) {
        books.removeAll()
        isLoading = true
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            let url = Searcher.urlWithSearchText(title, type)
            let jsonStr = Searcher.performRequestWithURL(url)
            if let jsonStr = jsonStr {
                if let dic = Searcher.parseJSON(jsonStr) {
                    if let result = Searcher.parseDictionary(dic) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.books = result
                            self.isLoading = false
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.books = [Books]()
                            self.isLoading = false
                        }
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert("Sorry", "Network error, please try later.")
                    self.isLoading = false
                    self.searchTableView.reloadData()
                }
            }
        }
    }

    /*
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

//MARK: - Search Bar
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadBooks(searchBar.text, "")
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

//MARK: - Table Data
extension SearchViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count == 0 ? 1: books.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as UITableViewCell
            let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            if (books.count == 0) {
                return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
                
                cell.titleLabel.text = books[indexPath.row].title
                if let bookPrice = books[indexPath.row].price {
                    cell.priceLabel.text = "$ \(bookPrice)"
                } else {
                    cell.priceLabel.text = ""
                }
                if let image = books[indexPath.row].image {
                    cell.coverImage.image = image
                }
                return cell
            }
        }
    }
    
    
}

//MARK: - Table Delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}

