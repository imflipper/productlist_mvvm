//
//  NetworkService+Product.swift
//
//  Created by flappa on 04.11.2024.
//

extension Business.ProductList.Product {
    
    public init(product: Reply.Products.Product) {
        self.init(id: product.id,
                  title: product.title ?? "",
                  description: product.description ?? "",
                  price: product.price ?? 0, stock: product.stock ?? 0,
                  images: product.images ?? [],
                  thumbnail: product.thumbnail ?? "")
    }
    
}
