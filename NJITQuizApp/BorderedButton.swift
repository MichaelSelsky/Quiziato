//
//  BorderedButton.swift
//  Quiziato™
//
//  Created by MichaelSelsky on 12/8/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }
    
    func sharedInit() {
        self.layer.borderColor = self.tintColor.CGColor
        self.layer.borderWidth = 4.0
        self.layer.cornerRadius = 8.0
        self.backgroundColor = self.tintColor
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
}
