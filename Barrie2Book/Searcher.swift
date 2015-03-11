//
//  Searcher.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-05.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Searcher {

    //return search url
    class func urlWithSearchText(searchText: String, _ searchType: String) -> NSURL {
        let escapedSearchText =
        searchText.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let urlString = "http://mycodeleaf.com/BookFinder/search.php?term=\(escapedSearchText)&type=\(searchType)"
//                let urlString = "http://mycodeleaf.com/BookFinder/search.php?term=\(escapedSearchText)&type=1"
        let url = NSURL(string: urlString)
        return url!
    }
    
    //internet request: (in subsequence)
    class func performRequestWithURL(url: NSURL) -> String? {
        var error: NSError?
        if let resultString = String(contentsOfURL: url,
                encoding: NSUTF8StringEncoding, error: &error) {
            return resultString
        } else {
            return nil
        }
    }
    
    //parse JSON
    class func parseJSON(data: NSData) -> [String: AnyObject]? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
            return json
        }
        return nil
    }

    //parse JSON dictionary
    class func parseDictionary(dictionary: [String: AnyObject]) -> [Books]? {
        let resultCount = dictionary["resultCount"] as Int
        if (resultCount > 0) {
            var resultBooks = [Books]()
            let resultType = dictionary["resultType"] as Int
            if (resultType == 1) {
                if let array: AnyObject = dictionary["results"] {
                    for singleDict in array as [AnyObject] {
                        if let singleDict = singleDict as? [String: AnyObject] {
                            var books = Books(title: singleDict["title"] as String)
                            books.ISBN = singleDict["ISBN"] as? String
                            books.edition = singleDict["edition"] as? String
                            books.author = singleDict["author"] as? String
                            if let url = singleDict["cover"] as? String {
                                books.imageUrl = "http://mycodeleaf.com/BookFinder/cover/\(url)"
//                                let imageData = NSData(contentsOfURL: NSURL(string: books.imageUrl)!)
//                                if imageData != nil {
//                                    books.image = UIImage(data: imageData!)
//                                }
                            }
                            books.owner = singleDict["owner"] as? String
                            if let degree = singleDict["degree"] as? String {
                                books.degree = "\(degree)% new"
                            }
                            books.price = singleDict["price"] as? String
                            resultBooks.append(books)
                        }
                    }
                }
                return resultBooks
            } else {
                if let array: AnyObject = dictionary["results"] {
                    for singleDict in array as [AnyObject] {
                        if let singleDict = singleDict as? [String: AnyObject] {
                            var books = Books(title: singleDict["title"] as String)
                            books.ISBN = singleDict["ISBN"] as? String
                            books.edition = singleDict["edition"] as? String
                            books.author = singleDict["author"] as? String
                            let url = singleDict["cover"] as? String
                            if let url = singleDict["cover"] as? String {
                                books.imageUrl = "http://mycodeleaf.com/BookFinder/cover/\(url)"
//                                let imageData = NSData(contentsOfURL: NSURL(string: books.imageUrl)!)
//                                if imageData != nil {
//                                    books.image = UIImage(data: imageData!)
//                                }
                            }
                            books.owner = singleDict["owner"] as? String
                            resultBooks.append(books)
                        }
                    }
                }
                return resultBooks
            }
        } else {
            return nil
        }
    }
    
    
}