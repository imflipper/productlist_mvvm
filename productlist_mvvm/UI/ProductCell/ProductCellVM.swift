//
//  ProductCellViewModel.swift
//  productlist_mvvm
//
//  Created by flappa on 20.11.2024.
//

import SwiftUI
import Combine

class ProductCellVM: ObservableObject, Identifiable, Equatable {
    
    enum Constants {
        static let spacing: CGFloat = 16
        static let imageSize = CGSize(width: 64, height: 64)
    }
    
    let id: Int
    let title: AttributedString
    let descr: AttributedString
    let price: AttributedString
    let qty: AttributedString
    let backgroundColor: Color
    
    var image: Image?
    var hasError: Bool = false
    @Published var isLoading: Bool = true
    
    private var imageLoadingTask: ManagedAsyncTask<Data?>?
    
    init(
        id: Int,
        title: AttributedString,
        descr: AttributedString,
        price: AttributedString,
        qty: AttributedString,
        imageLoadingTask: ManagedAsyncTask<Data?>?,
        backgroundColor: Color
    ) {
        self.id = id
        self.title = title
        self.descr = descr
        self.price = price
        self.qty = qty
        self.imageLoadingTask = imageLoadingTask ?? ManagedAsyncTask(taskClosure: { Data() })
        self.backgroundColor = backgroundColor
    }
    
    func loadImage() async {
        await MainActor.run {
            isLoading = true
            hasError = false
        }
        imageLoadingTask?.start()
        do {
            guard let data = try await imageLoadingTask?.task?.value else {
                throw URLError(.badServerResponse)
            }
            let resizedImage = try await resizeImage(data: data ?? Data())
            
            await MainActor.run {
                image = resizedImage
                isLoading = false
            }
        } catch {
            await handleImageLoadingError(error)
        }
    }
    
    private func resizeImage(data: Data) async throws -> Image? {
        return try await Task.detached {
            guard let uiImage = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            return Image(uiImage: uiImage.imageResized(to: Constants.imageSize))
        }.value
    }
    
    private func handleImageLoadingError(_ error: Error) async {
        await MainActor.run {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return
            }
            print("Error loading image: \(error.localizedDescription)")
            hasError = true
            isLoading = false
        }
    }
    
    func cancelImageLoading() {
        imageLoadingTask?.cancel()
    }
    
    static func == (lhs: ProductCellVM, rhs: ProductCellVM) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ProductCellVM {
    
    convenience init(product: Business.ProductList.Product,
                     imageLoadingTask: ManagedAsyncTask<Data?>?,
                     backgroundColor: Color) {
        
        let titleColor = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        })
        
        let priceColor = Color.green
        let qtyColor = Color.blue
        let descriptionColor = Color.gray
        
        var titleAttributedString = AttributedString(product.title)
        titleAttributedString.foregroundColor = titleColor
        titleAttributedString.font = .boldSystemFont(ofSize: 22)
        
        var descriptionAttributedString = AttributedString(product.description)
        descriptionAttributedString.foregroundColor = descriptionColor
        descriptionAttributedString.font = .systemFont(ofSize: 18)
        
        var priceAttributedString = AttributedString("Price: \(String(product.price))")
        priceAttributedString.foregroundColor = priceColor
        priceAttributedString.font = .boldSystemFont(ofSize: 16)
        
        var qtyAttributedString = AttributedString("Quantity: \(String(product.stock))")
        qtyAttributedString.foregroundColor = qtyColor
        qtyAttributedString.font = .italicSystemFont(ofSize: 15)
        
        self.init(
            id: product.id,
            title: titleAttributedString,
            descr: descriptionAttributedString,
            price: priceAttributedString,
            qty: qtyAttributedString,
            imageLoadingTask: imageLoadingTask,
            backgroundColor: backgroundColor
        )
    }
}
