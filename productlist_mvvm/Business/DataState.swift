//
//  DataState.swift
//
//  Created by flappa on 04.11.2024.
//

extension Business.Common {
    
    public enum DataState {
        
        public enum State {
            case error
            case loading
            case dataLoaded
            case allDataLoaded
            case noData
            case initial
            case undefined
            case permissionDenied
        }
        
    }
    
    
}
