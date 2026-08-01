# NNGetDeviceName

`NNGetDeviceName` is a small Swift package that converts the current iPhone or iPad hardware identifier into a readable device name.

The package has no third-party dependencies and does not write logs. Applications can use their own logging policy after obtaining the device name.

## Requirements

- iOS 14 or later
- Swift 5.9 or later

## Installation

In Xcode, select **File > Add Package Dependencies** and enter this repository's URL.

To use it from another `Package.swift` file:

```swift
dependencies: [
    .package(
        url: "https://github.com/nannan7/NNGetDeviceName.git",
        from: "1.0.0"
    )
]
```

Add `NNGetDeviceName` to the dependencies of the target that uses it.

## Usage

```swift
import NNGetDeviceName

let deviceName = NNGetDeviceName().getDeviceName()
```

Logging remains the responsibility of the application:

```swift
let deviceName = NNGetDeviceName().getDeviceName()
NNLog("Device name: %@", deviceName)
```

Known identifiers are converted to product names. Unknown identifiers are returned unchanged so that a newly released device remains identifiable until the mapping is updated.

On the simulator, the result uses the following format:

```text
Simulator(iPhone 16e)
```

## Testing

```sh
swift test
```

## License

NNGetDeviceName is available under the MIT License. See [LICENSE](LICENSE) for details.
