//
//  ManagedAsyncTask.swift
//
//  Created by flappa on 05.11.2024.
//

import Foundation

enum TaskState {
    case notStarted
    case running
    case completed
    case cancelled
}

public class ManagedAsyncTask<ResultType> {
    
    private(set) var task: Task<ResultType?, Error>?
    private(set) var state: TaskState = .notStarted
    
    private let taskClosure: () async throws -> ResultType?

    public init(taskClosure: @escaping () async throws -> ResultType?) {
        self.taskClosure = taskClosure
    }
    
    public func start() {
        guard state != .running else { return }

        state = .running
        task = Task { [weak self] in
            do {
                guard let self = self else { return nil }
                let result = try await self.taskClosure()
                self.state = .completed
                return result
            } catch {
                self?.state = .cancelled
                throw error
            }
        }
    }
    
    public func cancel() {
        task?.cancel()
        state = .cancelled
    }
  
}
