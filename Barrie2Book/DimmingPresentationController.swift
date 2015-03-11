//
//  DimmingPresentationController.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-10.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
