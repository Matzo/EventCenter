//
//  EventCenter.swift
//
//  Created by Ken Morishita on 2015/08/19.
//

import UIKit

public class EventCenter {
    static public let defaultCenter = EventCenter()
    
    public init() {
    }
    
    public func register<T>(observer: AnyObject, handler: T -> Void) {
        register(observer, queue: nil, handler:handler)
    }
    
    public func registerOnMainThread<T>(observer: AnyObject, handler: T -> Void) {
        register(observer, queue: dispatch_get_main_queue(), handler:handler)
    }
    
    public func register<T>(observer: AnyObject, queue: dispatch_queue_t?, handler: T -> Void) {
        dispatch_sync(EventCenter.operationQueue) {
            self.observers.append(ObserverInfo(observer: observer, key: nil, handler: handler, queue: queue))
        }
    }
    
    public func register<T,U:Equatable>(observer: AnyObject, key:U, handler: T -> Void) {
        register(observer, key:key, queue: nil, handler:handler)
    }
    
    public func registerOnMainThread<T,U:Equatable>(observer: AnyObject, key:U, handler: T -> Void) {
        register(observer, key:key, queue: dispatch_get_main_queue(), handler:handler)
    }
    
    public func register<T,U:Equatable>(observer: AnyObject, key:U, queue: dispatch_queue_t?, handler: T -> Void) {
        dispatch_sync(EventCenter.operationQueue) {
            self.observers.append(ObserverInfo(observer: observer, key:key, handler: handler, queue: queue))
        }
    }
    
    public func unregister(observer: AnyObject) {
        dispatch_sync(EventCenter.operationQueue) {
            self.observers = self.observers.filter { $0.observer !== observer }
        }
    }
    
    public func unregister<U:Equatable>(observer: AnyObject, key: U) {
        dispatch_sync(EventCenter.operationQueue) {
            self.observers = self.observers.filter { $0.observer !== observer && ($0.key as? U) != key }
        }
    }

    public func post<T>(obj: T) {
        for info in observers {
            if let h = info.handler as? (T -> Void) where info.key == nil {
                if let queue = info.queue {
                    dispatch_async(queue) { h(obj) }
                } else {
                    h(obj)
                }
            }
        }
    }
    
    public func post<T, U:Equatable>(obj: T, key:U) {
        for info in observers {
            if let h = info.handler as? (T -> Void), k = info.key as? U {
                if k != key {
                    continue
                }
                if let queue = info.queue {
                    dispatch_async(queue) { h(obj) }
                } else {
                    h(obj)
                }
            }
        }
    }
    

    static private let operationQueue = dispatch_queue_create("mokemokechicken.EventCenter", DISPATCH_QUEUE_SERIAL)
    private var observers = [ObserverInfo]()
    
    private struct ObserverInfo {
        let observer: AnyObject
        let key: Any?
        let handler: Any
        let queue: dispatch_queue_t?
    }
}


