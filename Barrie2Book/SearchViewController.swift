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
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        searchTableView.rowHeight = 80
        
//        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
//        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
//        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
//        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
