//
//  Utilities.swift
//
//  Created by flappa on 05.11.2024.
//
import Foundation

public protocol With {}

public extension With where Self: Any {
    @discardableResult
    func with(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: With {}
