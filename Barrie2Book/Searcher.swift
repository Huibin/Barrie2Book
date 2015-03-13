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
        let url = NSURL(string: urlString)
        return url!
    }
    
    //return sell book url
    class func urlWithSellBookText(title: String, _ author: String, _ edition: String, _ owner: String, _ degree: String, _ price: String, _ type: Int, _ delete: Int) -> NSURL {
        let titleText =
        title.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let authorText =
        author.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let urlString = "http://mycodeleaf.com/BookFinder/sellbook.php?title=\(titleText)&author=\(authorText)&edition=\(edition)&owner=\(owner)&degree=\(degree)&price=\(price)&type=\(type)&del=\(delete)"
        let url = NSURL(string: urlString)
        return url!
    }
    
    //return need book url
    class func urlWithNeedBookText(title: String, _ author: String, _ edition: String, _ owner: String, _ type: Int, _ delete: Int) -> NSURL {
        let titleText =
        title.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let authorText =
        author.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let urlString = "http://mycodeleaf.com/BookFinder/needbook.php?title=\(titleText)&author=\(authorText)&edition=\(edition)&owner=\(owner)&type=\(type)&del=\(delete)"
        let url = NSURL(string: urlString)
        return url!
    }
    
    //internet request: replaced by NSURLSession
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
                            books.type =  singleDict["type"] as? String
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
                            books.type =  singleDict["type"] as? String
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