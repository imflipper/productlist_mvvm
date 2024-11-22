//
//  Request.swift
//
//  Created by flappa on 04.11.2024.
//

import Foundation

public enum Requests {
    public enum Products {}
}

extension Requests.Products {
    
    public struct ProductsParams: Codable {
        
        public let limit: Int
        public let skip: Int
        
        public init(limit: Int, skip: Int) {
            self.limit = limit
            self.skip = skip
        }
        
    }
}
