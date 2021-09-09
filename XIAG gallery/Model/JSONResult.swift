//
//  JSONResult.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

struct JSONResult< T: Decodable >: Decodable {
    
    let results: [Image]?
    
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        results = try? container.decode([Image].self, forKey: .results)
    }
}
