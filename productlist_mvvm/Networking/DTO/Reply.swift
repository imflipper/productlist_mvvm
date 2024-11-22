//
//  Reply.swift
//
//  Created by flappa on 04.11.2024.
//

public enum Reply {
    public enum Products {}
}


extension Reply.Products {
    
    public struct ProductsReply: Codable, Equatable {
        let products: [Product]
        let total: Int?
        let skip: Int?
        let limit: Int?
    }
    
    public struct Product: Codable, Equatable {
        let id: Int
        let title: String?
        let description: String?
        let category: String?
        let price: Double?
        let discountPercentage: Double?
        let rating: Double?
        let stock: Int?
        let tags: [String]?
        let brand: String?
        let sku: String?
        let weight: Int?
        let dimensions: Dimensions?
        let warrantyInformation: String?
        let shippingInformation: String?
        let availabilityStatus: String?
        let reviews: [Review]?
        let returnPolicy: String?
        let minimumOrderQuantity: Int?
        let meta: Meta?
        let images: [String]?
        let thumbnail: String?
    }
    
    public struct Dimensions: Codable, Equatable {
        let width: Double?
        let height: Double?
        let depth: Double?
    }
    
    public struct Review: Codable, Equatable {
        let rating: Int?
        let comment: String?
        let date: String?
        let reviewerName: String?
        let reviewerEmail: String?
    }
    
    public struct Meta: Codable, Equatable {
        let createdAt: String?
        let updatedAt: String?
        let barcode: String?
        let qrCode: String?
    }
}
