//
//  SpotPhotoCollectionViewCell.swift
//  Snacktacular
//
//  Created by Brenden Picioane on 11/15/20.
//  Copyright © 2020 Brenden Picioane. All rights reserved.
//

import UIKit

class SpotPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var spot: Spot!
    var photo: Photo! {
        didSet {
            photo.loadImage(spot: spot) { (success) in
                if success {
                    self.photoImageView.image = self.photo.image
                } else {
                    print("L. no success loading photo in collection view cell.")
                }
            }
            
        }
    }
}
