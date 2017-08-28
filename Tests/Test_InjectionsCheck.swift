//
//  Test_InjectionsCheck.swift
//  InjectionsCheck
//

import Foundation
import XCTest
import InjectionsCheck

class Test_InjectionsCheck: XCTestCase {

    func testBasicInjectionsThrowsNoNils() {

        class TestClass {
            var testStringproperty: String?

            @objc
            var testIntProperty: NSNumber?
            var testObjectProperty: URLSession?
        }

        let testClass = TestClass()
        XCTAssertThrowsError(
            try checkInjections(testClass))
    }

    func testInjectionsCheckWithIgnores(){
        func testBasicInjectionsThrowsNoNils() {

            class TestClass {
                var testStringproperty: String? = "100"

                @objc
                var testIntProperty: NSNumber? = NSNumber(value: 10)
                var testObjectProperty: URLSession?
            }

            let testClass = TestClass()
            XCTAssertNoThrow(
                try checkInjections(testClass, ignoring: [
                    "testObjectProperty"
                    ]))
        }
    }

    func testBasicInjectionsNotThrowsOnValues () {

        class TestClass {
            var testStringproperty: String? = "InjectionsCheck"

            @objc
            var testIntProperty: NSNumber = NSNumber(value: 10)
            var testObjectProperty: URLSession? = URLSession(configuration: .default)
        }

        let testClass = TestClass()
        XCTAssertNoThrow(
            try checkInjections(testClass))
    }

    func testIgnoresAllDefaultSelectorTypes () {

        class TestClass {
            var testStringproperty: String?

            @objc
            var testIntProperty: NSNumber?
            @objc
            var testObjectProperty: URLSession?
        }

        let testClass = TestClass()
        XCTAssertNoThrow(
            try checkInjections(testClass, ignoring: [
                "testStringproperty",
                #selector(getter: TestClass.testIntProperty),
                #keyPath(TestClass.testObjectProperty)
                ]))
    }

    func testEnumAsIgnoreSelectorType () {

        class TestClass {

            enum SelectorsToIgnore: String, SelectorName {
                case testStringproperty
                case testIntProperty
                case testObjectProperty
            }

            var testStringproperty: String?
            var testIntProperty: NSNumber?
            var testObjectProperty: URLSession?
        }

        let testClass = TestClass()
        XCTAssertNoThrow(
            try checkInjections(testClass, ignoring: [
                TestClass.SelectorsToIgnore.testStringproperty,
                TestClass.SelectorsToIgnore.testIntProperty,
                TestClass.SelectorsToIgnore.testObjectProperty
                ]))
    }


    func testDebugInjectionsIsCalledOnNils() {

        class TestClass {
            var testStringproperty: String?
            var testIntProperty: Int?
            var testObjectProperty: URLSession?
        }

        let expectation = self.expectation(description: "FatalErrorClosureCalled")

        let testClass = TestClass()
        let result = debugCheckInjections(testClass, ignoring: []) { _ in expectation.fulfill() }
        XCTAssertNil(result)
        self.waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertNil(error)
        }
    }

    func testDebugInjectionsIsNotCalledOnValues() {

        class TestClass {
            var testStringproperty: String? = "lalala"
            var testIntProperty: Int? = 10
            var testObjectProperty: URLSession? = URLSession(configuration: .default)
        }

        let expectation = self.expectation(description: "FatalErrorClosureCalled")
        expectation.fulfill()
        expectation.assertForOverFulfill = true

        let testClass = TestClass()

        let result = debugCheckInjections(testClass, ignoring: []) { _ in expectation.fulfill() }
        XCTAssertNotNil(result)

        self.waitForExpectations(timeout: 1.0) { (error) in
            XCTAssertNil(error)
        }
    }


}
