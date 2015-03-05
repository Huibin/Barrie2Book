//
//  Books.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-05.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import Foundation

class Books {
    var title = "";
    var edition = "";
    var author = "";
    var publisher: String!
    var condition: String!
    var imageUrl: String!
    
    struct Type  {
        static let sell = "Sell"
        static let need = "Need"
    }
    
    struct Status {
        static let done = "Done"
        static let going = "Going"
    }
    
    
}