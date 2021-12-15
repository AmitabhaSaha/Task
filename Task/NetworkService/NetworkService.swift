//
//  NetworkService.swift
//  Task
//
//  Created by Amitabha Saha on 15/12/21.
//

import Foundation
import Alamofire

typealias ImageResult = Result<[Image], Error>

class NetworkService {
    
    class func getImages(completion: @escaping (_ result: ImageResult) -> Void) {
        
        let url = NetworkConstants.BasePath + NetworkConstants.images
        
        let request = AF.request(url)
        request.responseDecodable(of: ImageListData.self) { response in
            if let value = response.value {
                let items = value.data.children.map({ $0.data })
                completion(.success(items))
            } else if let error = response.error {
                completion(.failure(error))
            }
        }
    }
}
