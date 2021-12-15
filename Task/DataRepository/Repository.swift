//
//  Repository.swift
//  Task
//
//  Created by Amitabha Saha on 15/12/21.
//

import Foundation


class Repository {
    
    class func getImages(completion: @escaping (_ result: ImageResult) -> Void) {
        
        NetworkService.getImages(completion: completion)
    }
}
