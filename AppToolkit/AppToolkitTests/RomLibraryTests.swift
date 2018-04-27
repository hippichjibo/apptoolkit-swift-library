//
//  CommandRequesterTests.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import PromiseKit
@testable import AppToolkit

class CommandRequesterTests: XCTestCase {
//    var rom: CommandRequester!
    var mockDelegate: MockEventListenerDelegate!
    var mockRequester: MockCommandRequester!

    override func setUp() {
        super.setUp()
        mockDelegate = MockEventListenerDelegate()
        mockRequester = MockCommandRequester()
//        rom = CommandRequester()
//        rom.delegate = mockDelegate
//        rom.requester = mockRequester
    }

    // MARK: Public interface

    func testSuccessfulConnection() {
        mockRequester.connectionStatus = .connected
        let successHandler: CommandRequester.CompletionHandler = { succeed, error in
            XCTAssertTrue(succeed)
        }

//        rom.connect(successHandler: successHandler)
    }

    func testFailedConnection() {
        mockRequester.connectionStatus = .unconnected
        let successHandler: CommandRequester.CompletionHandler = { succeed, error in
            XCTAssertFalse(succeed)
        }

//        rom.connect(successHandler: successHandler)
    }

    func testErrorConnection() {
        mockRequester.connectionStatus = .error
        let errorHandler: CommandRequester.CompletionHandler = { succeed,error in
            XCTAssertNotNil(error)
        }

//        rom.connect(errorHandler: errorHandler)
    }

    // MARK: - EventListenerDelegate

    func testInvalidEventDoesNotNotifyListener() {
        let mockEvent: EventMessage = JSONLoader().loadObject(forResource: "invalidEventMessage", ofType: "json")!
//        rom.didReceiveEventMessage(mockEvent)
        XCTAssertFalse(mockDelegate.didReceiveVideoCalled)
    }

    func testDidReceiveTakeVideoEvent() {
        let mockEvent: EventMessage = JSONLoader().loadObject(forResource: "videoEvent", ofType: "json")!
//        rom.didReceiveEventMessage(mockEvent)
        XCTAssertTrue(mockDelegate.didReceiveVideoCalled)
    }

    func testDidReceiveTakePhotoEvent() {
        let mockEvent: EventMessage = JSONLoader().loadObject(forResource: "takePhotoEvent", ofType: "json")!
//        rom.didReceiveEventMessage(mockEvent)
        XCTAssertTrue(mockDelegate.didReceivePhotoCalled)
    }

    func testDidReceiveLookAtAchievedEvent() {
        let mockEvent: EventMessage = JSONLoader().loadObject(forResource: "lookAtAchievedEvent", ofType: "json")!
//        rom.didReceiveEventMessage(mockEvent)
        XCTAssertTrue(mockDelegate.didReceiveLookAtAchievedCalled)
    }
}
