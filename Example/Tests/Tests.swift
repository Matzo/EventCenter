// https://github.com/Quick/Quick

import Quick
import Nimble
import EventCenter

class EventCenterSpec: QuickSpec {
    var called2: Int = 0
    
    override func spec() {
        afterEach {
            EventCenter.defaultCenter.unregister(self)
        }
        
        describe("EventCenter Basic") {

            it("can register and unregister Handler") {
                let ec = EventCenter.defaultCenter  // use default EventCenter
                var called = 0
                ec.register(self) { (num: Int) in
                    expect(num) == 99
                    called += 1
                }
                ec.post(99)
                

                ec.unregister(self)
                ec.post(100)  // not handled
                
                ec.register(self) { (num: Int) in
                    expect(num) == 101
                    called += 1
                }
                ec.post(101)

                expect(called) == 2
            }
            
            it("Only Called Correct Type Handler") {
                let ec = EventCenter()  // can use original EventCenter
                
                var called = 0
                ec.register(self) { (num: Int) in
                    expect(num) == 200
                    called += 1
                }
                ec.register(self) { (s: String) in
                    expect(s) == "yes!"
                    called += 1
                }
                
                ec.post(200)
                ec.post("yes!")
                expect(called) == 2
            }
            
            it("Event Message can be Class Instance and Struct Value") {
                let ec = EventCenter.defaultCenter
                var called = 0
                self.called2 = 0
                
                ec.register(self) { (event: MyEvent) in
                    expect(event.num) == 50
                    called += 1
                }
                
                ec.register(self) { (event: ChildEvent) in
                    expect(event.num) == 60
                    called += 1
                }
                
                ec.register(self) { (event: MyEventStruct) in
                    expect(event.name) == "struct event"
                    called += 1
                }
                
                ec.register(self) { (event: EnumEvent) in
                    called += 1
                    switch (event) {
                    case .success(let code):
                        expect(code) == 200
                    case .error(let code):
                        expect(code) == 500
                    }
                }
                
                ec.register(self, handler: self.myHandler)
                
                ec.post(MyEvent(num: 50))
                ec.post(ChildEvent(num: 60))
                ec.post(MyEventStruct(name: "struct event"))
                ec.post(EnumEvent.success(code: 200))
                ec.post(EnumEvent.error(code: 500))
                
                expect(called) == 5
                expect(self.called2) == 1
            }
        }
        
        describe("EventCenter and Thread") {
            it("can register a handler called on main thread") {
                let ec = EventCenter.defaultCenter
                var called = 0
                
                ec.registerOnMainThread(self) { (num: Int) in
                    expect(num) == 30
                    expect(Thread.isMainThread) == true
                    called += 1
                }
                
                ec.register(self) { (num: Int) in
                    expect(num) == 30
                    expect(Thread.isMainThread) == false
                    called += 1                }

                ec.register(self, queue: DispatchQueue.global()) { (num: Int) in
                    expect(num) == 30
                    expect(Thread.isMainThread) == false
                    called += 1
                }
                

                DispatchQueue.global().async {
                    expect(Thread.isMainThread) == false
                    ec.post(30)
                }

                Thread.sleep(forTimeInterval: 1.0)

                waitUntil { done in
                    Thread.sleep(forTimeInterval: 0.9)
                    expect(called) == 3
                    done()
                }
            }
        }
        
        describe("EventCenter with key") {

            it("can register with key and unregister Handler") {
                let ec = EventCenter.defaultCenter  // use default EventCenter
                var called = 0
                ec.register(self, key:"key") { (num: Int) in
                    expect(num) == 99
                    called += 1
                }
                ec.post(99, key:"key")
                

                ec.unregister(self, key:"key")
                ec.post(100, key:"key")  // not handled
                
                ec.register(self, key:EnumKey.success) { (num: Int) in
                    expect(num) == 101
                    called += 1
                }
                ec.post(101, key:EnumKey.success)

                expect(called) == 2
            }
            
            it("Only Called Correct key") {
                let ec = EventCenter()  // can use original EventCenter
                
                var called = 0

                ec.register(self, key:EnumKey.success) { (num: Int) in
                    expect(num) == 200
                    called += 1
                }
                ec.register(self, key:EnumKey.success) { (s: String) in
                    expect(s) == "yes!"
                    called += 1
                }
                ec.register(self, key:"yes!") { (s: String) in
                    expect(s) == "yes!"
                    called += 1
                }
                
                ec.post(200, key:EnumKey.success)
                ec.post("yes!", key:EnumKey.success)
                ec.post("yes!", key:"yes!")
                
                ec.post("yes!", key:"yes?")
                ec.post("yes!", key:EnumKey.error)
                expect(called) == 3
            }
            
        }
    }
    
    func myHandler(_ event: MyEvent) {
        expect(event.num) == 50
        called2 += 1
    }
    
}

class MyEvent {
    let num: Int
    init(num: Int) {
        self.num = num
    }
}

class ChildEvent : MyEvent {}

struct MyEventStruct {
    let name: String
}

enum EnumEvent {
    case success(code: Int)
    case error(code: Int)
}

enum EnumKey {
    case success
    case error
}

//        describe("these will fail") {
//
//            it("can do maths") {
//                expect(1) == 2
//            }
//
//            it("can read") {
//                expect("number") == "string"
//            }
//
//            it("will eventually fail") {
//                expect("time").toEventually( equal("done") )
//            }
//
//            context("these will pass") {
//
//                it("can do maths") {
//                    expect(23) == 23
//                }
//
//                it("can read") {
//                    expect("🐮") == "🐮"
//                }
//
//                it("will eventually pass") {
//                    var time = "passing"
//
//                    dispatch_async(dispatch_get_main_queue()) {
//                        time = "done"
//                    }
//
//                    waitUntil { done in
//                        NSThread.sleepForTimeInterval(0.5)
//                        expect(time) == "done"
//
//                        done()
//                    }
//                }
//            }
//        }
