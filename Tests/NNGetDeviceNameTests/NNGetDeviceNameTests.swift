//
//  NNGetDeviceNameTests.swift
//  NNGetDeviceNameTests
//
//  Verifies identifier mapping and simulator display-name behavior.
//

import XCTest

@testable import NNGetDeviceName

final class NNGetDeviceNameTests: XCTestCase {
    func testKnownIPhoneIdentifierReturnsReadableName() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPhone17,5",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPhone 16e")
    }

    func testLatestIPhoneIdentifierReturnsReadableName() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPhone18,5",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPhone 17e")
    }

    func testKnownIPodIdentifierReturnsReadableName() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPod9,1",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPod touch (7th generation)")
    }

    func testKnownIPod5IdentifierReturnsReadableName() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPod5,1",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPod touch")
    }

    func testKnownIPod6IdentifierReturnsReadableName() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPod7,1",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPod touch (6th generation)")
    }

    func testKnownHistoricalIPodIdentifiersReturnReadableNames() {
        let expectedNames = [
            "iPod1,1": "iPod touch",
            "iPod2,1": "iPod touch (2nd generation)",
            "iPod3,1": "iPod touch (3rd generation)",
            "iPod4,1": "iPod touch (4th generation)",
        ]

        for (identifier, expectedName) in expectedNames {
            let name = NNGetDeviceName.deviceName(
                rawIdentifier: identifier,
                simulatorModelIdentifier: nil,
                isSimulator: false
            )

            XCTAssertEqual(name, expectedName, identifier)
        }
    }

    func testKnownIPadIdentifierReturnsReadableName() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPad16,6",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPad Pro 13-inch (M4)")
    }

    func testLatestIPadIdentifierReturnsReadableName() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPad17,3",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPad Pro 13-inch (M5)")
    }

    func testUnknownIdentifierIsReturnedUnchanged() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPhone99,1",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPhone99,1")
    }

    func testSimulatorUsesMappedModelIdentifier() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "arm64",
            simulatorModelIdentifier: "iPhone18,4",
            isSimulator: true
        )

        XCTAssertEqual(name, "Simulator(iPhone Air)")
    }

    func testSimulatorWithoutModelIdentifierUsesRawIdentifier() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "arm64",
            simulatorModelIdentifier: nil,
            isSimulator: true
        )

        XCTAssertEqual(name, "Simulator(arm64)")
    }

    func testEmptySimulatorModelIdentifierUsesRawIdentifier() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "x86_64",
            simulatorModelIdentifier: "",
            isSimulator: true
        )

        XCTAssertEqual(name, "Simulator(x86_64)")
    }
}
