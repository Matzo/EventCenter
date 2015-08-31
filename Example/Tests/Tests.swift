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
                    called++
                }
                ec.post(99)
                

                ec.unregister(self)
                ec.post(100)  // not handled
                
                ec.register(self) { (num: Int) in
                    expect(num) == 101
                    called++
                }
                ec.post(101)

                expect(called) == 2
            }
            
            it("Only Called Correct Type Handler") {
                let ec = EventCenter()  // can use original EventCenter
                
                var called = 0
                ec.register(self) { (num: Int) in
                    expect(num) == 200
                    called++
                }
                ec.register(self) { (s: String) in
                    expect(s) == "yes!"
                    called++
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
                    called++
                }
                
                ec.register(self) { (event: ChildEvent) in
                    expect(event.num) == 60
                    called++
                }
                
                ec.register(self) { (event: MyEventStruct) in
                    expect(event.name) == "struct event"
                    called++
                }
                
                ec.register(self) { (event: EnumEvent) in
                    called++
                    switch (event) {
                    case .SUCCESS(let code):
                        expect(code) == 200
                    case .ERROR(let code):
                        expect(code) == 500
                    }
                }
                
                ec.register(self, handler: self.myHandler)
                
                ec.post(MyEvent(num: 50))
                ec.post(ChildEvent(num: 60))
                ec.post(MyEventStruct(name: "struct event"))
                ec.post(EnumEvent.SUCCESS(code: 200))
                ec.post(EnumEvent.ERROR(code: 500))
                
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
                    expect(NSThread.isMainThread()) == true
                    called++
                }
                
                ec.register(self) { (num: Int) in
                    expect(num) == 30
                    expect(NSThread.isMainThread()) == false
                    called++
                }
                
                ec.register(self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { (num: Int) in
                    expect(num) == 30
                    expect(NSThread.isMainThread()) == false
                    called++
                }
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    expect(NSThread.isMainThread()) == false
                    ec.post(30)
                }
                
                NSThread.sleepForTimeInterval(1.0)

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.9)
                    expect(called) == 3
                    done()
                }
            }
        }
        
        describe("EventCenter with EventType") {

            it("can register with event and unregister Handler") {
                let ec = EventCenter.defaultCenter  // use default EventCenter
                var called = 0
                ec.register(self, event:"event") { (num: Int) in
                    expect(num) == 99
                    called++
                }
                ec.post(99, event:"event")
                

                ec.unregister(self, event:"event")
                ec.post(100, event:"event")  // not handled
                
                ec.register(self, event:EnumEventType.SUCCESS) { (num: Int) in
                    expect(num) == 101
                    called++
                }
                ec.post(101, event:EnumEventType.SUCCESS)

                expect(called) == 2
            }
            
            it("Only Called Correct Event Type") {
                let ec = EventCenter()  // can use original EventCenter
                
                var called = 0

                ec.register(self, event:EnumEventType.SUCCESS) { (num: Int) in
                    expect(num) == 200
                    called++
                }
                ec.register(self, event:EnumEventType.SUCCESS) { (s: String) in
                    expect(s) == "yes!"
                    called++
                }
                ec.register(self, event:"yes!") { (s: String) in
                    expect(s) == "yes!"
                    called++
                }
                
                ec.post(200, event:EnumEventType.SUCCESS)
                ec.post("yes!", event:EnumEventType.SUCCESS)
                ec.post("yes!", event:"yes!")
                
                ec.post("yes!", event:"yes?")
                ec.post("yes!", event:EnumEventType.ERROR)
                expect(called) == 3
            }
            
        }
    }
    
    func myHandler(event: MyEvent) {
        expect(event.num) == 50
        called2++
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
    case SUCCESS(code: Int)
    case ERROR(code: Int)
}

enum EnumEventType {
    case SUCCESS
    case ERROR
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
