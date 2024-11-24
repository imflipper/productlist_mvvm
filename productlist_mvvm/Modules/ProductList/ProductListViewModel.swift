//
//  ViewModel.swift
//  productlist_mvvm
//
//  Created by flappa on 20.11.2024.
//

import SwiftUI


class ProductListViewModel: ObservableObject {
    
    @Published var cells: [ProductCellVM] = []
    @Published var errorMessage: String? = nil
    private lazy var worker: ProductListWorking = ProductListWorker(network: NetworkService())
    let backgroundColor: Color = Color.black.opacity(0.05)
    let navBarTitle = "Product List"
    func refreshProducts() {
        worker.clear()
        cells.removeAll()
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            loadProducts()
        }
    }
    
    func loadProducts() {
        Task {
            do {
                try await worker.fetchProducts()
                await MainActor.run {
                    let prods = worker.products
                    let cells = prods.map { product in
                        let image = product.images.first ?? ""
                        let imageLoadingTask = worker.imageLoadingTasks[image]
                        return ProductCellVM(product: product, imageLoadingTask: imageLoadingTask, backgroundColor: .clear)
                    }
                    self.cells = cells
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load products. Please try again later."
                }
            }
        }
    }
    
    func loadMoreProductsIfNeeded(currentProductId: Int) async {
        guard !worker.products.isEmpty, let lastProduct = worker.products.last else { return }
        if currentProductId == lastProduct.id {
            self.loadProducts()
        }
    }
    
}


