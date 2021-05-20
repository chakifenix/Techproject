//
//  Presenter.swift
//  StreamChatCore
//
//  Created by Alexey Bukhtin on 16/06/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// A general presenter for making requests with pagination.
public class Presenter<T> {
    
    /// A list of presenter items.
    public internal(set) var items = [T]()
    /// A pagination of an initial page size, e.g. .limit(25)
    var pageSize: Pagination
    /// A pagination for the next request.
    var next: Pagination
    /// Checks if presenter items are empty.
    public var isEmpty: Bool { return items.isEmpty }
    let loadPagination = PublishSubject<Pagination>()
    
    private(set) lazy var connectionErrors: Driver<ViewChanges> = Client.shared.connection
        .map { connection -> ViewChanges? in
            if case .disconnected(let error) = connection, let webSocketError = error as? WebSocket.Error {
                return .error(AnyError(error: webSocketError))
            }
            
            return nil
        }
        .unwrap()
        .asDriver(onErrorJustReturn: .none)
    
    init(pageSize: Pagination) {
        self.pageSize = pageSize
        self.next = pageSize
    }
    
    /// Prepare a request with pagination when the web socket is connected.
    ///
    /// - Parameter pagination: an initial page size (see `Pagination`).
    /// - Returns: an observable pagination for a request.
    public func prepareRequest(startPaginationWith pagination: Pagination = .none) -> Observable<Pagination> {
        let connectionObservable = Client.shared.connection.connected { [weak self] isConnected in
            if !isConnected, let self = self, !self.items.isEmpty {
                self.items = []
                self.next = self.pageSize
            }
        }
        
        return Observable.combineLatest(loadPagination.asObserver().startWith(pagination), connectionObservable)
            .map { pagination, _ in pagination }
            .filter { [weak self] in
                if let self = self, self.items.isEmpty, $0 != self.pageSize {
                    DispatchQueue.main.async { self.loadPagination.onNext(self.pageSize) }
                    return false
                }
                
                return true
            }
            .share()
    }
    
    /// Reload items.
    public func reload() {
        next = pageSize
        items = []
        load(pagination: pageSize)
    }
    
    /// Load the next page of items.
    public func loadNext() {
        if next != pageSize {
            load(pagination: next)
        }
    }
    
    private func load(pagination: Pagination) {
        loadPagination.onNext(pagination)
    }
}
