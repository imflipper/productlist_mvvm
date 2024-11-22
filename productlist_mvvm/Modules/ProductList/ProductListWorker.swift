//
//  ProductListWorker.swift
//  productlist_mvvm
//
//  Created by flappa on 21.11.2024.
//

import Foundation

protocol ProductListWorking {
    
    var products: [Business.ProductList.Product] { get }
    var imageLoadingTasks: [String: ManagedAsyncTask<Data?>] { get }
    
    func fetchProducts() async throws
    func loadImageData(urlString: String) async throws -> ManagedAsyncTask<Data?>?
    func clear()
}

class ProductListWorker: ProductListWorking {
    
    private enum Constants {
        static let limit: Int = 20
    }
    
    var currentPage = 0
    var imageLoadingTasks: [String: ManagedAsyncTask<Data?>] = [:]
    private(set) var state: Business.Common.DataState.State = .undefined
    var products: [Business.ProductList.Product] = []
    
    private let network: NetworkServicing
    
    init(network: NetworkServicing) {
        self.network = network
    }
    
    func fetchProducts() async throws {
        guard state != .loading else { return }
        
        state = .loading
        
        if !products.isEmpty {
            currentPage += 1
        }
        
        do {
            let params = Requests.Products.ProductsParams(limit: Constants.limit, skip: currentPage * Constants.limit)
            let response = try await network.fetchProducts(params: params)
            let newItems = response.products.map { Business.ProductList.Product(product: $0) }
            
            if !newItems.isEmpty {
                self.products += newItems
                for product in newItems {
                    if let imageUrl = product.images.first {
                        imageLoadingTasks[imageUrl] = try await loadImageData(urlString: imageUrl)
                    }
                }
                state = .dataLoaded
            } else {
                state = .allDataLoaded
            }
        } catch {
            state = .error
            throw error
        }
    }
    
    func loadImageData(urlString: String) async throws -> ManagedAsyncTask<Data?>? {
        
        let retryableTask: ManagedAsyncTask<Data?> = ManagedAsyncTask { [weak self] in
            do {
                let data = try await self?.network.getImageData(urlString: urlString)
                return data
            } catch {
                throw error
            }
        }
        
        return retryableTask
    }
    
    func clear() {
        currentPage = 0
        products.removeAll()
        imageLoadingTasks.removeAll()
        state = .initial
    }
    
}
