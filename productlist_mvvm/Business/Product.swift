//
//  Product.swift
//
//  Created by flappa on 04.11.2024.
//


extension Business.ProductList {
    
    public struct Product: Identifiable, Equatable {
        public let id: Int
        public let title: String
        public let description: String
        public let price: Double
        public let stock: Int
        public let images: [String]
        public let thumbnail: String
    }
    
}



