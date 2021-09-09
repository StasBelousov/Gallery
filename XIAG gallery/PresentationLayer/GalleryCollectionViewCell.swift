//
//  GalleryCollectionViewCell.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var imageName: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.clipsToBounds = true
        self.shadowView.makeShadow(to: self.shadowView)
        self.thumbnailImageView.layer.cornerRadius = self.shadowView.layer.cornerRadius
        self.backgroundColor = .white
        self.thumbnailImageView.contentMode = .scaleAspectFill
    }
    
    func setUI(image: UIImage, name: String) {
        thumbnailImageView.image = image
        imageName.text = name
    }
}

