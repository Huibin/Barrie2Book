//
//  Books.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-05.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import Foundation
import UIKit

struct Books {
    var ISBN: String!
    var title: String!
    var edition: String!
    var author: String!
    var publisher: String!
    var imageUrl: String!

    var type: String!      // 1-sell, 0-need, 9-keep
    var degree: String! // 80% new
    var price: String!  // $ 12.00
    var owner: String!

    init(title: String) {
        self.title = title
    }


}