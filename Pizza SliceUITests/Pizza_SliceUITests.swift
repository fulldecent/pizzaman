//
//  Pizza_SliceUITests.swift
//  Pizza SliceUITests
//
//  Created by Full Decent on 3/3/16.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import XCTest

class Pizza_SliceUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        snapshot("01Intro")

        let element = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.tap()
        
        snapshot("02Begin")
        
        sleep(8)
        
        snapshot("03GameOver")
        XCTAssertTrue(true)
    }
    
}
