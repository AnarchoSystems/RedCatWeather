//
//  Requestable.swift
//  RedCatWeather
//
//  Created by Markus Pfeifer on 14.05.21.
//

import Foundation
import RedCat



enum Requestable<Request : Equatable, Response : Equatable> : Equatable, Emptyable {
    
    case requested(request: Request)
    case resolved(response: Response)
    case failed(reason: NSError)
    case empty
    
    mutating func finalize(from response: Result<Response, NSError>) {
        
        switch response {
        
        case .success(let value):
            self = .resolved(response: value)
            
        case .failure(let error):
            self = .failed(reason: error)
            
        }
        
    }
    
}
