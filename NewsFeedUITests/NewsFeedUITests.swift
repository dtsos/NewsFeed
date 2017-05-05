//
//  NewsFeedUITests.swift
//  NewsFeedUITests
//
//  Created by David Trivian S on 5/3/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import XCTest

class NewsFeedUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    func testBackground(){
        XCUIDevice.shared().orientation = .portrait
        
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        let element = collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).swipeUp()
        element.swipeUp()
        XCUIDevice.shared().orientation = .portrait
       
        XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).swipeUp()
        
        
        collectionViewsQuery.staticTexts["5 comments"].swipeDown()
        
        let cell = collectionViewsQuery.children(matching: .cell).element(boundBy: 0)
        let element2 = cell.children(matching: .other).element.children(matching: .other).element
        element2.children(matching: .other).element(boundBy: 1).tap()
        
        let element3 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element3.tap()
        element3.tap()
        cell.staticTexts["Sat, 09 Jan 2016"].tap()
        element2.swipeUp()
        
    }
    
    func testRefreshControl(){
        
        let collectionViewsQuery = XCUIApplication().collectionViews
        let cell = collectionViewsQuery.children(matching: .cell).element(boundBy: 0)
        let element = cell.children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).swipeDown()
        element.swipeLeft()
        collectionViewsQuery.staticTexts["David Mark"].tap()
        element.swipeLeft()
        element.swipeDown()
        element.swipeDown()
        element.swipeDown()
        cell.staticTexts["Sat, 09 Jan 2016"].swipeDown()
        
    }
    
}
