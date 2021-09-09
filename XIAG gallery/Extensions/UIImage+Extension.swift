//
//  UIImage+Extension.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

import UIKit

extension UIImage {
    
    static func named(_ name: String) -> UIImage {
        if let image = UIImage(named: name) {
            return image
        } else {
            return UIImage()
        }
    }
}

