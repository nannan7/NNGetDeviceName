//
//  NNGetDeviceName.swift
//  NNGetDeviceName
//
//  Converts the current iOS hardware identifier into a readable device name.
//

import Darwin
import Foundation

/// Converts the current iPhone or iPad hardware identifier into a readable device name.
///
/// Unknown identifiers are returned unchanged so that newly released devices remain identifiable.
/// Simulator names are returned in the form `Simulator(iPhone 16e)`.
@objcMembers
@objc(NNGetDeviceName)
public final class NNGetDeviceName: NSObject {

    private enum Constants {
        static let sysctlMachineKey = "hw.machine"
        static let simulatorModelEnvironmentKey = "SIMULATOR_MODEL_IDENTIFIER"
        static let simulatorPrefix = "Simulator"
        static let unknownIdentifier = "unknown"
    }

    // Values returned by hw.machine when running on Intel or Apple silicon simulators.
    private static let simulatorArchitectures: Set<String> = [
        "i386",
        "x86_64",
        "arm64",
    ]

    private static let deviceMap: [String: String] = [
        "iPhone1,1": "iPhone",
        "iPhone1,2": "iPhone 3G",
        "iPhone2,1": "iPhone 3GS",
        "iPhone3,1": "iPhone 4",
        "iPhone3,2": "iPhone 4",
        "iPhone3,3": "iPhone 4",
        "iPhone4,1": "iPhone 4S",
        "iPhone5,1": "iPhone 5",
        "iPhone5,2": "iPhone 5",
        "iPhone5,3": "iPhone 5c",
        "iPhone5,4": "iPhone 5c",
        "iPhone6,1": "iPhone 5s",
        "iPhone6,2": "iPhone 5s",
        "iPhone7,1": "iPhone 6 Plus",
        "iPhone7,2": "iPhone 6",
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone8,4": "iPhone SE (1st generation)",
        "iPhone9,1": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus",
        "iPhone9,3": "iPhone 7",
        "iPhone9,4": "iPhone 7 Plus",
        "iPhone10,1": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus",
        "iPhone10,3": "iPhone X",
        "iPhone10,4": "iPhone 8",
        "iPhone10,5": "iPhone 8 Plus",
        "iPhone10,6": "iPhone X",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE (2nd generation)",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,6": "iPhone SE (3rd generation)",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",
        "iPhone18,1": "iPhone 17 Pro",
        "iPhone18,2": "iPhone 17 Pro Max",
        "iPhone18,3": "iPhone 17",
        "iPhone18,4": "iPhone Air",

        "iPad1,1": "iPad",
        "iPad2,1": "iPad 2",
        "iPad2,2": "iPad 2",
        "iPad2,3": "iPad 2",
        "iPad2,4": "iPad 2",
        "iPad2,5": "iPad mini",
        "iPad2,6": "iPad mini",
        "iPad2,7": "iPad mini",
        "iPad3,1": "iPad (3rd Gen)",
        "iPad3,2": "iPad (3rd Gen)",
        "iPad3,3": "iPad (3rd Gen)",
        "iPad3,4": "iPad (4th Gen)",
        "iPad3,5": "iPad (4th Gen)",
        "iPad3,6": "iPad (4th Gen)",
        "iPad4,1": "iPad Air",
        "iPad4,2": "iPad Air",
        "iPad4,3": "iPad Air",
        "iPad4,4": "iPad mini Retina",
        "iPad4,5": "iPad mini Retina",
        "iPad4,6": "iPad mini Retina",
        "iPad4,7": "iPad mini 3",
        "iPad4,8": "iPad mini 3",
        "iPad4,9": "iPad mini 3",
        "iPad5,1": "iPad mini 4",
        "iPad5,2": "iPad mini 4",
        "iPad5,3": "iPad Air 2",
        "iPad5,4": "iPad Air 2",
        "iPad6,3": "iPad Pro (9.7)",
        "iPad6,4": "iPad Pro (9.7)",
        "iPad6,7": "iPad Pro (12.9)",
        "iPad6,8": "iPad Pro (12.9)",
        "iPad6,11": "iPad (5th Gen)",
        "iPad6,12": "iPad (5th Gen)",
        "iPad7,1": "iPad Pro (12.9 2nd Gen)",
        "iPad7,2": "iPad Pro (12.9 2nd Gen)",
        "iPad7,3": "iPad Pro (10.5)",
        "iPad7,4": "iPad Pro (10.5)",
        "iPad7,5": "iPad (6th Gen)",
        "iPad7,6": "iPad (6th Gen)",
        "iPad7,11": "iPad (7th Gen)",
        "iPad7,12": "iPad (7th Gen)",
        "iPad8,1": "iPad Pro (11)",
        "iPad8,2": "iPad Pro (11)",
        "iPad8,3": "iPad Pro (11)",
        "iPad8,4": "iPad Pro (11)",
        "iPad8,5": "iPad Pro (12.9 3rd Gen)",
        "iPad8,6": "iPad Pro (12.9 3rd Gen)",
        "iPad8,7": "iPad Pro (12.9 3rd Gen)",
        "iPad8,8": "iPad Pro (12.9 3rd Gen)",
        "iPad8,9": "iPad Pro (11 2nd Gen)",
        "iPad8,10": "iPad Pro (11 2nd Gen)",
        "iPad8,11": "iPad Pro (12.9 4th Gen)",
        "iPad8,12": "iPad Pro (12.9 4th Gen)",
        "iPad11,1": "iPad mini 5",
        "iPad11,2": "iPad mini 5",
        "iPad11,3": "iPad Air 3",
        "iPad11,4": "iPad Air 3",
        "iPad11,6": "iPad (8th Gen)",
        "iPad11,7": "iPad (8th Gen)",
        "iPad12,1": "iPad (9th Gen)",
        "iPad12,2": "iPad (9th Gen)",
        "iPad13,1": "iPad Air 4",
        "iPad13,2": "iPad Air 4",
        "iPad13,4": "iPad Pro (11 3rd Gen)",
        "iPad13,5": "iPad Pro (11 3rd Gen)",
        "iPad13,6": "iPad Pro (11 3rd Gen)",
        "iPad13,7": "iPad Pro (11 3rd Gen)",
        "iPad13,8": "iPad Pro (12.9 5th Gen)",
        "iPad13,9": "iPad Pro (12.9 5th Gen)",
        "iPad13,10": "iPad Pro (12.9 5th Gen)",
        "iPad13,11": "iPad Pro (12.9 5th Gen)",
        "iPad13,16": "iPad Air 5",
        "iPad13,17": "iPad Air 5",
        "iPad13,18": "iPad (10th Gen)",
        "iPad13,19": "iPad (10th Gen)",
        "iPad14,1": "iPad mini 6",
        "iPad14,2": "iPad mini 6",
        "iPad14,3": "iPad Pro (11 4th Gen)",
        "iPad14,4": "iPad Pro (11 4th Gen)",
        "iPad14,5": "iPad Pro (12.9 6th Gen)",
        "iPad14,6": "iPad Pro (12.9 6th Gen)",
        "iPad14,8": "iPad Air (11 6th Gen)",
        "iPad14,9": "iPad Air (11 6th Gen)",
        "iPad14,10": "iPad Air (13 6th Gen)",
        "iPad14,11": "iPad Air (13 6th Gen)",
        "iPad15,7": "iPad (A16)",
        "iPad15,8": "iPad (A16)",
        "iPad16,1": "iPad mini (A17 Pro)",
        "iPad16,2": "iPad mini (A17 Pro)",
        "iPad16,3": "iPad Pro (11 5th Gen)",
        "iPad16,4": "iPad Pro (11 5th Gen)",
        "iPad16,5": "iPad Pro (13 7th Gen)",
        "iPad16,6": "iPad Pro (13 7th Gen)",
    ]

    /// Creates a device-name provider.
    public override init() {
        super.init()
    }

    /// Returns the readable name of the current iPhone, iPad, or simulator.
    ///
    /// If the hardware identifier is not registered yet, the identifier itself is returned.
    public func getDeviceName() -> String {
        let rawIdentifier = Self.hardwareIdentifier()
        let simulatorModelIdentifier = ProcessInfo.processInfo.environment[
            Constants.simulatorModelEnvironmentKey
        ]
        return Self.deviceName(
            rawIdentifier: rawIdentifier,
            simulatorModelIdentifier: simulatorModelIdentifier,
            isSimulator: Self.isSimulator(rawIdentifier: rawIdentifier)
        )
    }

    static func deviceName(
        rawIdentifier: String,
        simulatorModelIdentifier: String?,
        isSimulator: Bool
    ) -> String {
        let resolvedIdentifier: String
        if isSimulator,
            let simulatorModelIdentifier,
            !simulatorModelIdentifier.isEmpty
        {
            resolvedIdentifier = simulatorModelIdentifier
        } else {
            resolvedIdentifier = rawIdentifier
        }

        let mappedName = deviceMap[resolvedIdentifier] ?? resolvedIdentifier
        guard isSimulator else {
            return mappedName
        }
        return "\(Constants.simulatorPrefix)(\(mappedName))"
    }

    private static func isSimulator(rawIdentifier: String) -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return simulatorArchitectures.contains(rawIdentifier)
        #endif
    }

    private static func hardwareIdentifier() -> String {
        var size: size_t = 0
        let firstResult = sysctlbyname(Constants.sysctlMachineKey, nil, &size, nil, 0)
        guard firstResult == 0, size > 0 else {
            return Constants.unknownIdentifier
        }

        var buffer = [CChar](repeating: 0, count: Int(size))
        let secondResult: Int32 = buffer.withUnsafeMutableBufferPointer { pointer in
            sysctlbyname(Constants.sysctlMachineKey, pointer.baseAddress, &size, nil, 0)
        }
        guard secondResult == 0 else {
            return Constants.unknownIdentifier
        }

        return String(cString: buffer)
    }
}
