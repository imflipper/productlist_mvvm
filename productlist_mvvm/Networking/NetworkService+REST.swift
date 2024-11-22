//
//  NetworkService+REST.swift
//
//  Created by flappa on 04.11.2024.
//

import Foundation


// MARK: - GET


public enum RequestType: String {
    case get = "GET"
}

public enum NetworkError: Error {
    case invalidURL
    case badResponse
}

typealias HTTPHeaders = [String: String]

extension NetworkService {
    
    
    func getData(from urlString: String, headers: HTTPHeaders? = nil) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        
        if let cachedResponse = cache.cachedResponse(for: URLRequest(url: url)) {
            return cachedResponse.data
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = RequestType.get.rawValue

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse
        }

        
        let cachedResponse = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
        
        
        return data
        
    }
            
    func getRequest<P: Encodable, R: Decodable>(endpointName: String, parameters: P, headers: HTTPHeaders? = nil) async throws -> R {
        
        currentGetTask?.cancel()
        
        let url = StoredParams().baseUrl.appendingPathComponent(endpointName)
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = try parametersToQueryItems(parameters)
        
        guard let finalURL = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = RequestType.get.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        currentGetTask = Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.badResponse
                }
                
                let decodedResponse = try JSONDecoder().decode(R.self, from: data)
                return decodedResponse
            } catch {
                throw error
            }
        }
        
        let result = try await currentGetTask?.value
        
        return result as! R
    }
    
    
}

extension NetworkService {
    
    fileprivate func parametersToQueryItems<P: Encodable>(_ parameters: P) throws -> [URLQueryItem] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(parameters)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        var queryItems: [URLQueryItem] = []
        
        if let dict = json as? [String: Any] {
            for (key, value) in dict {
                let item = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(item)
            }
        }
        
        return queryItems
    }
    
}


