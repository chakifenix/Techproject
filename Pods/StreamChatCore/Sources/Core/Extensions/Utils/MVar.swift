//
//  MVar.swift
//  StreamChatCore
//
//  Created by Alexey Bukhtin on 25/06/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A mutable thread safe variable.
public final class MVar<T> {
    /// A didSet callback type.
    public typealias DidSetCallback = (T?) -> Void
    
    private let queue = DispatchQueue(label: "io.getstream.Chat.MVar", qos: .utility, attributes: .concurrent)
    private var value: T?
    private var didSet: DidSetCallback?
    
    /// Init a MVar.
    ///
    /// - Parameters:
    ///   - value: an initial value.
    ///   - didSet: a didSet callback.
    public init(_ value: T? = nil, _ didSet: DidSetCallback? = nil) {
        self.value = value
        self.didSet = didSet
    }
    
    /// Set a value.
    public func set(_ newValue: T?) {
        queue.async(flags: .barrier) {
            self.value = newValue
            self.didSet?(newValue)
        }
    }
    
    /// Get the value.
    public func get() -> T? {
        var currentValue: T?
        queue.sync { currentValue = self.value }
        return currentValue
    }
    
    /// Get the value if exists or return a default value.
    ///
    /// - Parameter defaultValue: a default value.
    /// - Returns: a stored value or default.
    public func get(defaultValue: T) -> T {
        return get() ?? defaultValue
    }
}

// MARK: - Helper Operator

public extension MVar where T == Int {
    
    static func += (lhs: MVar<T>, rhs: T) {
        if let currentValue = lhs.get() {
            lhs.set(currentValue + rhs)
        }
    }
    
    static func -= (lhs: MVar<T>, rhs: T) {
        if let currentValue = lhs.get() {
            lhs.set(currentValue - rhs)
        }
    }
}
