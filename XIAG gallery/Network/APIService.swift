//
//  APIService.swift
//  XIAG gallery
//
//  Created by Станислав Белоусов on 03.09.2021.
//

import Foundation

class APIService {
    
    static let shared = APIService()
    var urlSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func fetchImages(completion: @escaping (Result<[Image], Error>) -> Void) {
        
        dataTask?.cancel()
        
        if let currentURL = URL(string: defaultURLString) {
            print(currentURL)
            dataTask = urlSession.dataTask(with: currentURL) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                if let error = error {
                    completion(.failure(error))
                } else if let data = data,
                          let response = response as? HTTPURLResponse,
                          response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode([Image].self, from: data)
                        completion(.success(json))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
}
