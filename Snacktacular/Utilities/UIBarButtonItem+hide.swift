//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Brenden Picioane on 11/14/20.
//  Copyright © 2020 Brenden Picioane. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
