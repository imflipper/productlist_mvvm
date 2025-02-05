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
    
    
    // Структура
    struct MyStruct {
        var value: Int
    }

    // Класс
    class MyClass {
        var value: Int
        
        init(value: Int) {
            self.value = value
        }
    }

    // Функция для тестирования производительности структуры
    func testStructPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var structs = [MyStruct]()
        for i in 0..<1000000 {
            structs.append(MyStruct(value: i))
        }
        
        // Изменение значений в массиве
        for i in 0..<1000000 {
            structs[i].value += 1
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        print("Struct performance time: \(endTime - startTime) seconds")
    }

    // Функция для тестирования производительности класса
    func testClassPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var classes = [MyClass]()
        for i in 0..<1000000 {
            classes.append(MyClass(value: i))
        }
        
        // Изменение значений в массиве
        for i in 0..<1000000 {
            classes[i].value += 1
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        print("Class performance time: \(endTime - startTime) seconds")
    }

    
    
}


