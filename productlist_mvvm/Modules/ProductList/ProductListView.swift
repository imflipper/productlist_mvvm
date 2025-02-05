//
//  ContentView.swift
//  productlist_mvvm
//
//  Created by flappa on 20.11.2024.
//

import SwiftUI

struct ProductListView: View {
    
    @StateObject private var viewModel = ProductListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(8)
                        .background(.red)
                        .cornerRadius(5)
                }
                if viewModel.cells.isEmpty {
                    createProgressStack()
                } else {
                    List(viewModel.cells) { vm in
                        self.createProductCell(vm: vm)
                    }
                    .scrollContentBackground(.hidden)
                    .background(viewModel.backgroundColor)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.cells)
            .navigationTitle(viewModel.navBarTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadProducts()
            }
            .refreshable {
                viewModel.refreshProducts()
            }.background(viewModel.backgroundColor)
        }
        
    }
}

extension ProductListView {
    
    func createProgressStack() -> some View {
        return VStack {
            ProgressView()
                .scaleEffect(1.1)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 0)
    }
    
    func createProductCell(vm: ProductCellVM) -> some View {
        return ProductCell(viewModel: vm).onAppear {
            Task {
                await self.viewModel.loadMoreProductsIfNeeded(currentProductId: vm.id)
            }
        }
    }
}


#Preview {
    ProductListView()
}
