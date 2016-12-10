//
//  ViewController.swift
//  EventCenter
//
//  Created by Ken Morishita on 08/27/2015.
//  Copyright (c) 2015 Ken Morishita. All rights reserved.
//

import UIKit
import EventCenter


class ViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        let ec = EventCenter.defaultCenter
        
        
        // Handlers called only when the posted object-type is equal to the hander's arg-type.
        ec.register(self) { (event: MyAwesomeModel.UpdateEvent) in
            print("update view! 1")
        }
        
        ec.register(self) { (event: MyAwesomeModel.StoreEvent) in
            switch(event) {
            case .success:
                print("store ok!")
            case .error:
                print("store error!")
            }
        }
        
        // or
        
        ec.register(self, handler: self.onEvent)
        
        // or
        
        ec.registerOnMainThread(self, handler: self.onEvent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        EventCenter.defaultCenter.unregister(self)
    }
    
    func updateView() {
        print("update view! 2")
    }
    
    func onEvent(_ event: MyAwesomeModel.UpdateEvent) {
        self.updateView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        MyAwesomeModel().notifyUpdate()
        MyAwesomeModel().notifyStoreResult()
    }
}


class MyAwesomeModel {
    class UpdateEvent {}
    enum StoreEvent {
        case success
        case error
    }
    
    func notifyUpdate() {
        EventCenter.defaultCenter.post(UpdateEvent())
    }
    
    func notifyStoreResult() {
        EventCenter.defaultCenter.post(StoreEvent.success)
    }
}



// If you want to see more cases, see also Tests.swift
