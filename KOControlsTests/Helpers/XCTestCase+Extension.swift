//
//  XCTestCase+Extension.swift
//  KOControlsTests
//
//  Created by Kuba Ostrowski on 10/07/2019.
//  Copyright © 2019 Kuba Ostrowski. All rights reserved.
//

import XCTest

extension XCTestCase {
    func wait(timeout: TimeInterval) {
        let expection = expectation(description: "wait expection")
        let timeout = timeout + 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            expection.fulfill()
        }
        waitForExpectations(timeout: timeout + 0.1, handler: nil)
    }
}
