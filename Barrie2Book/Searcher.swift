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
    
    class func urlWithShowText(searchType: String, _ username: String) -> NSURL {
        let urlString = "http://mycodeleaf.com/BookFinder/search.php?term=&type=\(searchType)&user=\(username)"
        let url = NSURL(string: urlString)
        return url!
    }
    
    //return sell book url
    class func urlWithSellBookText(ISBN: String, _ title: String, _ author: String, _ edition: String, _ publisher: String, _ cover: String, _ owner: String, _ degree: String, _ price: String, _ type: Int) -> NSURL {
        let titleText =
        title.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let authorText =
        author.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let coverText = cover.stringByReplacingOccurrencesOfString("&", withString: "nbsp", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let urlString = "http://mycodeleaf.com/BookFinder/sellbook.php?ISBN=\(ISBN)&title=\(titleText)&author=\(authorText)&edition=\(edition)&publisher=\(publisher)&cover=\(coverText)&owner=\(owner)&degree=\(degree)&price=\(price)&type=\(type)"
        let url = NSURL(string: urlString)
        return url!
    }
    
    //return need book url: 0:add, 1:del, 2:edit, 9:keep
    class func urlWithNeedBookText(ISBN: String, _ title: String, _ author: String, _ edition: String, _ publisher: String, _ cover: String, _ owner: String, _ type: Int) -> NSURL {
        let titleText =
        title.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let authorText =
        author.stringByAddingPercentEscapesUsingEncoding(
            NSUTF8StringEncoding)!
        let coverText = cover.stringByReplacingOccurrencesOfString("&", withString: "nbsp", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let urlString = "http://mycodeleaf.com/BookFinder/needbook.php?ISBN=\(ISBN)&title=\(titleText)&author=\(authorText)&edition=\(edition)&publisher=\(publisher)&cover=\(coverText)&owner=\(owner)&type=\(type)"
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
                            books.imageUrl = singleDict["cover"] as? String
//                            if let url = singleDict["cover"] as? String {
//                                books.imageUrl = "http://mycodeleaf.com/BookFinder/cover/\(url)"
//                            }
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
                            books.imageUrl = singleDict["cover"] as? String
//                            if let url = singleDict["cover"] as? String {
//                                books.imageUrl = "http://mycodeleaf.com/BookFinder/cover/\(url)"
//                            }
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
    
    //parse JSON dictionary
    class func parseGoogleAPI(dictionary: [String: AnyObject]) -> Books? {
        let resultCount = dictionary["totalItems"] as Int
        if (resultCount == 1) {
            let resultArr = dictionary["items"] as [AnyObject]
            let resultDic = resultArr[0] as [String: AnyObject]
            let volumeInfo = resultDic["volumeInfo"] as [String: AnyObject]
            var title = volumeInfo["title"] as String
            if let subtitle = volumeInfo["subtitle"] as? String {
                title = "\(title): \(subtitle)"
            }
            var book = Books(title: title)
            book.edition = volumeInfo["publishedDate"] as? String
            book.publisher = volumeInfo["publisher"] as? String
            if let authorArr = volumeInfo["authors"] as? [String] {
                var authors = ""
                for signle in authorArr {
                    authors += "\(signle), "
                }
                book.author = authors
            }
            if let imagesUrlDic = volumeInfo["imageLinks"] as? [String: String] {
                book.imageUrl = imagesUrlDic["smallThumbnail"]! as String
            }
            return book
        } else {
            return nil
        }
    }
    
}