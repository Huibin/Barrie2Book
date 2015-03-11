//
//  Validation.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-11.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import Foundation


class Validation {
    
    var username: String!
    var password: String!
    
    private func validation() -> Bool {
        return username == nil ? false: true
    }
    
}