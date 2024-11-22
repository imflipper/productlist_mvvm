//
//  ProductListWorkerTests.swift
//  productlist_mvvm
//
//  Created by flappa on 21.11.2024.
//


import XCTest
@testable import productlist_mvvm

final class ProductListWorkerTests: XCTestCase {
    
    class MockNetworkService: NetworkServicing {
        
        var fetchProductsResult: Result<Reply.Products.ProductsReply, Error> = .failure(NSError(domain: "", code: -1, userInfo: nil))
        var getImageDataResult: Result<Data, Error> = .failure(NSError(domain: "", code: -1, userInfo: nil))
        
        func fetchProducts(params: Requests.Products.ProductsParams) async throws -> Reply.Products.ProductsReply {
            switch fetchProductsResult {
            case .success(let reply):
                return reply
            case .failure(let error):
                throw error
            }
        }
        
        func getImageData(urlString: String) async throws -> Data {
            switch getImageDataResult {
            case .success(let data):
                return data
            case .failure(let error):
                throw error
            }
        }
    }
    
    var worker: ProductListWorker!
    var mockNetwork: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkService()
        worker = ProductListWorker(network: mockNetwork)
    }
    
    override func tearDown() {
        worker = nil
        mockNetwork = nil
        super.tearDown()
    }
    
    func testFetchProductsSuccess() async throws {
        let testProduct = Reply.Products.Product(
            id: 1,
            title: "title",
            description: "description",
            category: "category",
            price: 1,
            discountPercentage: 1,
            rating: 1,
            stock: 1,
            tags: ["tag1", "tag2"],
            brand: "brand",
            sku: "sku",
            weight: 2,
            dimensions: Reply.Products.Dimensions(width: 10.0, height: 20.0, depth: 5.0),
            warrantyInformation: "warrantyInformation",
            shippingInformation: "shippingInformation",
            availabilityStatus: "availabilityStatus",
            reviews: [Reply.Products.Review(rating: 5, comment: "comment", date: "2023-11-06", reviewerName: "reviewerName", reviewerEmail: "reviewerEmail@mail.com")],
            returnPolicy: "returnPolicy",
            minimumOrderQuantity: 1,
            meta: Reply.Products.Meta(createdAt: "2023-11-06T12:00:00Z", updatedAt: "2023-11-06T12:00:00Z", barcode: "1234", qrCode: "1111"),
            images: ["https://dummyimage.com/test.png"],
            thumbnail: "https://dummyimage.com/thumbnail-test.png"
        )
        let reply = Reply.Products.ProductsReply(
            products: [testProduct],
            total: 1,
            skip: 1,
            limit: 1
        )
        mockNetwork.fetchProductsResult = .success(reply)
        mockNetwork.getImageDataResult = .success(Data())
        
        try await worker.fetchProducts()
        
        XCTAssertEqual(worker.products.count, 1, "Products should contain one item.")
        XCTAssertEqual(worker.products.first?.title, "title", "Product title should match.")
        XCTAssertEqual(worker.state, .dataLoaded, "State should be dataLoaded.")
        XCTAssertNotNil(worker.imageLoadingTasks["https://dummyimage.com/test.png"], "Image loading task should exist for the image URL.")
    }
    
    func testFetchProductsEmptyResponse() async throws {
        
        let reply = Reply.Products.ProductsReply(
            products: [],
            total: 1,
            skip: 1,
            limit: 1
        )
        mockNetwork.fetchProductsResult = .success(reply)
        
        try await worker.fetchProducts()
        
        XCTAssertTrue(worker.products.isEmpty, "Products should be empty.")
        XCTAssertEqual(worker.state, .allDataLoaded, "State should be allDataLoaded.")
    }
    
    func testFetchProductsFailure() async {
        let error = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockNetwork.fetchProductsResult = .failure(error)
        
        do {
            try await worker.fetchProducts()
            XCTFail("Expected fetchProducts to throw an error.")
        } catch {
            XCTAssertEqual(worker.state, .error, "State should be error.")
        }
    }
    
    func testClear() {
        worker.products = [Business.ProductList.Product(id: 1, title: "Test Product", description: "Description", price: 10.0, stock: 1, images: ["image_url"], thumbnail: "thumbnail_url")]
        worker.imageLoadingTasks = ["image_url": ManagedAsyncTask { nil }]
        worker.currentPage = 2
        
        worker.clear()
        
        XCTAssertTrue(worker.products.isEmpty, "Products should be cleared.")
        XCTAssertTrue(worker.imageLoadingTasks.isEmpty, "Image loading tasks should be cleared.")
        XCTAssertEqual(worker.state, .initial, "State should be initial.")
        XCTAssertEqual(worker.currentPage, 0, "Current page should be reset to 0.")
    }
    
    func testLoadImageDataSuccess() async throws {
        let imageData = Data([0x01, 0x02, 0x03])
        mockNetwork.getImageDataResult = .success(imageData) 

        let task = try await worker.loadImageData(urlString: "image_url")
        task?.start()
        
        XCTAssertNotNil(task, "Task should not be nil.")

        do {
            let result = try await task?.task?.value
            XCTAssertEqual(result, imageData, "The returned image data should match the expected data.")
        } catch {
            XCTFail("Task execution should not throw an error, but it threw: \(error)")
        }
    }
    
    func testLoadImageDataFailure() async throws {
        let error = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockNetwork.getImageDataResult = .failure(error)
        
        do {
            let task = try await worker.loadImageData(urlString: "https://dummyimage.com/test.png")
            task?.start()
            _ = try await task?.task?.value
            XCTFail("Expected loadImageData to throw an error.")
        } catch {
            XCTAssertNotNil(error, "Expected error to be thrown.")
        }
    }
}
