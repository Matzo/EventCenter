//
//  EventCenter.swift
//
//  Created by Ken Morishita on 2015/08/19.
//

import UIKit

open class EventCenter {
    static public let defaultCenter = EventCenter()
    
    public init() {
    }
    
    open func register<T>(_ observer: AnyObject, handler: @escaping (T) -> Void) {
        register(observer, queue: nil, handler:handler)
    }
    
    open func registerOnMainThread<T>(_ observer: AnyObject, handler: @escaping (T) -> Void) {
        register(observer, queue: DispatchQueue.main, handler:handler)
    }
    
    open func register<T>(_ observer: AnyObject, queue: DispatchQueue?, handler: @escaping (T) -> Void) {
        EventCenter.operationQueue.sync {
            self.observers.append(ObserverInfo(observer: observer, handler: handler, queue: queue))
        }
    }
    
    open func unregister(_ observer: AnyObject) {
        EventCenter.operationQueue.sync {
            self.observers = self.observers.filter { $0.observer != nil && $0.observer !== observer }
        }
    }
    
    open func post<T>(_ obj: T) {
        for info in observers {
            if let h = info.handler as? ((T) -> Void), equalsHandlerType(obj, handler: info.handler) {
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
        let handler: Any
        let queue: DispatchQueue?
        init<T>(observer: AnyObject, handler: @escaping (T) -> Void, queue: DispatchQueue?) {
            self.observer = observer
            self.handler = handler as Any
            self.queue = queue
        }
    }
}


