//
//  EventCenter.swift
//
//  Created by Ken Morishita on 2015/08/19.
//

import UIKit

open class EventCenter {
    static open let defaultCenter = EventCenter()
    
    public init() {
    }
    
    open func register<T>(_ observer: AnyObject, handler: (T) -> Void) {
        register(observer, queue: nil, handler:handler)
    }
    
    open func registerOnMainThread<T>(_ observer: AnyObject, handler: (T) -> Void) {
        register(observer, queue: DispatchQueue.main, handler:handler)
    }
    
    open func register<T>(_ observer: AnyObject, queue: DispatchQueue?, handler: (T) -> Void) {
        EventCenter.operationQueue.sync {
            self.observers.append(ObserverInfo(observer: observer, key: nil, handler: handler, queue: queue))
        }
    }
    
    open func register<T,U:Equatable>(_ observer: AnyObject, key:U, handler: (T) -> Void) {
        register(observer, key:key, queue: nil, handler:handler)
    }
    
    open func registerOnMainThread<T,U:Equatable>(_ observer: AnyObject, key:U, handler: (T) -> Void) {
        register(observer, key:key, queue: DispatchQueue.main, handler:handler)
    }
    
    open func register<T,U:Equatable>(_ observer: AnyObject, key:U, queue: DispatchQueue?, handler: (T) -> Void) {
        EventCenter.operationQueue.sync {
            self.observers.append(ObserverInfo(observer: observer, key:key, handler: handler, queue: queue))
        }
    }
    
    open func unregister(_ observer: AnyObject) {
        EventCenter.operationQueue.sync {
            self.observers = self.observers.filter { $0.observer != nil && $0.observer !== observer }
        }
    }
    
    open func unregister<U:Equatable>(_ observer: AnyObject, key: U) {
        EventCenter.operationQueue.sync {
            self.observers = self.observers.filter { $0.observer != nil && $0.observer !== observer && ($0.key as? U) != key }
        }
    }

    open func post<T>(_ obj: T) {
        for info in observers {
            if let h = info.handler as? ((T) -> Void), info.key == nil && equalsHandlerType(obj, handler: info.handler) {
                if let queue = info.queue {
                    queue.async { h(obj) }
                } else {
                    h(obj)
                }
            }
        }
    }
    
    open func post<T, U:Equatable>(_ obj: T, key:U) {
        for info in observers {
            if let h = info.handler as? ((T) -> Void), let k = info.key as? U, equalsHandlerType(obj, handler: info.handler) {
                if k != key {
                    continue
                }
                if let queue = info.queue {
                    queue.async { h(obj) }
                } else {
                    h(obj)
                }
            }
        }
    }
    
    fileprivate func equalsHandlerType<T>(_ obj: T, handler:Any) -> Bool {
        return Mirror(reflecting: handler).subjectType is ((T) -> Void).Type
    }

    static fileprivate let operationQueue = DispatchQueue(label: "mokemokechicken.EventCenter", attributes: [])
    fileprivate var observers = [ObserverInfo]()
    
    fileprivate struct ObserverInfo {
        weak var observer: AnyObject?
        let key: Any?
        let handler: Any
        let queue: DispatchQueue?
    }
}


