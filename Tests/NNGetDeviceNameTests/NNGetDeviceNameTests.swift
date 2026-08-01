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

    func testKnownIPadIdentifierReturnsReadableName() {
        let name = NNGetDeviceName.deviceName(
            rawIdentifier: "iPad16,6",
            simulatorModelIdentifier: nil,
            isSimulator: false
        )

        XCTAssertEqual(name, "iPad Pro (13 7th Gen)")
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
