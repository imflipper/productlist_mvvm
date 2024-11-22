//
//  NetworkService.swift
//
//  Created by flappa on 04.11.2024.
//

import Foundation

protocol NetworkServicing {
    
    func fetchProducts(params: Requests.Products.ProductsParams) async throws -> Reply.Products.ProductsReply
    func getImageData(urlString: String) async throws -> Data
}

public class NetworkService: NetworkServicing {
        
    private enum EndpointName {
        static let products = "products"
    }
    
    var currentGetTask: Task<Any, Error>?
    let cache = URLCache(memoryCapacity: 300 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024, diskPath: nil)
    
    func getImageData(urlString: String) async throws -> Data {
        return try await getData(from: urlString)
    }
    
    func fetchProducts(params: Requests.Products.ProductsParams) async throws -> Reply.Products.ProductsReply {
        return try await getRequest(endpointName: EndpointName.products, parameters: params)
    }
    
}



