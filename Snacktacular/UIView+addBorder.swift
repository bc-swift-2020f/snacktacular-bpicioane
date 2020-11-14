//
//  UIView+addBorder.swift
//  Snacktacular
//
//  Created by Brenden Picioane on 11/14/20.
//  Copyright © 2020 Brenden Picioane. All rights reserved.
//

import UIKit

extension UIView {
    
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
    }
    
    func noBorder() {
        self.layer.borderWidth = 0.0
    }
}
