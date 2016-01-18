//
//  FixedSplitViewController.swift
//  iClicker2000™
//
//  Created by MichaelSelsky on 11/23/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

class FixedSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }
}
