//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Ike Mattice on 7/11/16.
//  Copyright © 2016 Ike Mattice. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
