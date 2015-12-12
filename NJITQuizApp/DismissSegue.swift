//
//  DIsmissSegue.swift
//  Quiziato™
//
//  Created by MichaelSelsky on 12/12/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
    override func perform() {
        self.sourceViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
