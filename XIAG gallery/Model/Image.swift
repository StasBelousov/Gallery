//
//  Image.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

import Foundation

struct Image: Decodable {
    
    let imageURL: String?
    let thumbnailURL: String?
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "url"
        case thumbnailURL = "url_tn"
        case name
    }
}
