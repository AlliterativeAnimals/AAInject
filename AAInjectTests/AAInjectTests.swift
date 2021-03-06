//
//  AAInjectTests.swift
//  AAInjectTests
//
//  Created by David Godfrey on 21/10/2017.
//  Copyright © 2017 Alliterative Animals. All rights reserved.
//

import XCTest
@testable import AAInject

class AAInjectTests: XCTestCase {
    
    private var injector: AAInjector = AAInjector()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.injector = AAInjector()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleProperties() {
        let key = "testProperty"
        let value = "hello world"
        self.injector.setProperty(key, value: value)
        
        XCTAssertEqual(try self.injector.getProperty(key), value, "Should return the property when available")
    }
    
    func testInjectProperty() {
        let name = "John Smith"
        
        self.injector.setProperty("name", value: name)
        
        self.injector.register(ExampleClass.self) { (injector) throws -> ExampleClass in
            return ExampleClass(name: try injector.getProperty("name"))
        }
        
        XCTAssertEqual(try self.injector.inject(ExampleClass.self).name, name, "Expect injected property to match")
    }
    
    func testSharesInstances() {
        self.injector.setProperty("name", value: "John Smith")
        
        self.injector.register(ExampleClass.self) { (injector) throws -> ExampleClass in
            return ExampleClass(name: try injector.getProperty("name"))
        }
        
        XCTAssert(try self.injector.inject(ExampleClass.self) === self.injector.inject(ExampleClass.self), "Expect injected services to be reused")
    }
    
    func testDeepInjection() {
        let name = "John Smith"
        
        self.injector.setProperty("name", value: name)
        
        self.injector.register(ExampleClass.self) { (injector) throws -> ExampleClass in
            return ExampleClass(name: try injector.getProperty("name"))
        }
        
        self.injector.register(ExampleWrapperClass.self) { (injector) -> ExampleWrapperClass in
            return ExampleWrapperClass.init(contents: try injector.inject(ExampleClass.self))
        }
        
        XCTAssertEqual(try self.injector.inject(ExampleWrapperClass.self).contents.name, name, "Expect deep-injected property to match")
    }
}

class ExampleClass {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

class ExampleWrapperClass {
    let contents: ExampleClass
    
    init(contents: ExampleClass) {
        self.contents = contents
    }
}
