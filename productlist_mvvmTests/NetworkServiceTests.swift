//
//  MockProductParams.swift
//
//  Created by flappa on 05.11.2024.
//


import XCTest
@testable import productlist_mvvm

final class NetworkServiceTests: XCTestCase {
    
    var networkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        networkService = MockNetworkService()
    }
    
    override func tearDown() {
        networkService.mockResponseData = nil
        networkService.mockError = nil
        networkService = nil
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
        let expectedReply = Reply.Products.ProductsReply(
            products: [testProduct],
            total: 1,
            skip: 1,
            limit: 1
        )
        
        networkService.mockResponseData = try JSONEncoder().encode(expectedReply)
        
        let params = Requests.Products.ProductsParams(limit: 1, skip: 1)
        let reply = try await networkService.fetchProducts(params: params)
        
        XCTAssertEqual(reply, expectedReply, "Products should match")
    }
    
    func testFetchProductsFailureWithURLError() async {
        networkService.mockError = URLError(.badURL)
        do {
            let params = Requests.Products.ProductsParams(limit: 1, skip: 1)
            _ = try await networkService.fetchProducts(params: params)
            XCTFail("Expected URLError")
        } catch {
            XCTAssertTrue(error is URLError, "Expected URLError")
        }
    }
    
    func testFetchProductsFailureWithError() async {
        networkService.mockError = NSError(domain: "domain", code: 500, userInfo: nil)
        
        do {
            let params = Requests.Products.ProductsParams(limit: 1, skip: 1)
            _ = try await networkService.fetchProducts(params: params)
            XCTFail("Expected error")
        } catch {
            XCTAssertFalse(error is URLError, "Expected error")
        }
    }
    
    func testGetImageDataSuccess() async throws {
        let expectedData = Data("data".utf8)
        
        networkService.mockResponseData = expectedData
        
        let urlString = "https://dummyimage.com/test.png"
        let data = try await networkService.getImageData(urlString: urlString)
        
        XCTAssertEqual(data, expectedData, "No matching data in testGetImageDataSuccess")
    }
    
    func testGetImageDataFailureWithURLError() async {
        networkService.mockError = URLError(.badURL)
        do {
            _ = try await networkService.getImageData(urlString: "https://dummyimage.com/test.png")
            XCTFail("URLError Expected")
        } catch {
            XCTAssertTrue(error is URLError, "URLError Expected")
        }
    }
    
    func testGetImageDataFailureWithError() async {
        networkService.mockError = NSError(domain: "domain", code: 404, userInfo: nil)
        do {
            _ = try await networkService.getImageData(urlString: "https://dummyimage.com/test.png")
            XCTFail("Expected error")
        } catch {
            XCTAssertFalse(error is URLError, "Expected error")
        }
    }
}

class MockNetworkService: NetworkServicing {
    
    var mockResponseData: Data?
    var mockError: Error?
    var shouldReturnError = false
    
    func fetchProducts(params: Requests.Products.ProductsParams) async throws -> Reply.Products.ProductsReply {
        if let error = mockError { throw error }
        if shouldReturnError {
            throw NSError(domain: "NetworkError", code: 1, userInfo: nil)
        }
        guard let data = mockResponseData else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(Reply.Products.ProductsReply.self, from: data)
    }
    
    func getImageData(urlString: String) async throws -> Data {
        if let error = mockError { throw error }
        guard let data = mockResponseData else { throw URLError(.badURL) }
        return data
    }
}



