//
//  ProductCellView.swift
//  productlist_mvvm
//
//  Created by flappa on 20.11.2024.
//

import SwiftUI

struct ProductCell: View {
    
    let constants = ProductCellVM.Constants.self
    @StateObject var viewModel: ProductCellVM
    var body: some View {
        VStack(alignment: .center, spacing: ProductCellVM.Constants.spacing) {
            if viewModel.isLoading {
                ProgressView().frame(width: constants.imageSize.width, height: constants.imageSize.height)
            } else if let image = viewModel.image {
                image.aspectRatio(contentMode: .fit)
            } else if viewModel.hasError {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.red)
                    .frame(width: constants.imageSize.width, height: constants.imageSize.height)
                    .onTapGesture {
                        Task { await viewModel.loadImage() }
                    }
            } else {
                Color.clear
                    .frame(width: constants.imageSize.width, height: constants.imageSize.height)
            }
            
            VStack(alignment: .leading, spacing: constants.spacing / 2) {
                Text(viewModel.title)
                Text(viewModel.descr)
                    .lineLimit(nil)
                Text(viewModel.price)
                Text(viewModel.qty)
            }
        }
        .padding(constants.spacing)
        .background(viewModel.backgroundColor)
        .onAppear {
            Task {
                await viewModel.loadImage()
            }
        }
        .onDisappear {
            viewModel.cancelImageLoading()
        }
        
    }
}
