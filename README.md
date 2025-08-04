# TelemetryKit

A Swift library for tracking user interactions and sending telemetry data in OTLP (OpenTelemetry Protocol) format to your metrics endpoint.

## Features

- **Screen Tracking**: Automatically track when screens appear
- **Navigation Tracking**: Track navigation between screens with different methods (tab, push, modal, etc.)
- **Button Interaction Tracking**: Track button taps with context
- **Product Interaction Tracking**: Track product-related actions (view, add to cart, purchase, etc.)
- **Custom Event Tracking**: Track any custom events with attributes
- **OTLP Format**: Send data in OpenTelemetry Protocol format
- **SwiftUI Integration**: Easy-to-use SwiftUI modifiers and extensions
- **Configurable**: Customize endpoint, API key, service name, and more
- **Session Tracking**: Automatic session ID generation and tracking

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/TelemetryKit.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to File → Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

## Quick Start

### 1. Configure the Service

In your app's main entry point (e.g., `App.swift`):

```swift
import SwiftUI
import TelemetryKit

@main
struct MyApp: App {
    init() {
        TelemetryService.shared.configure(
            endpointURL: URL(string: "https://your-otlp-endpoint.com/v1/traces")!,
            apiKey: "your-api-key-here",
            serviceName: "MyApp",
            serviceVersion: "1.0.0",
            enabled: true
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Track Screens

Use the `.trackScreen()` modifier:

```swift
struct ProductListView: View {
    var body: some View {
        List {
            // Your content
        }
        .trackScreen("ProductList")
    }
}
```

### 3. Track Button Interactions

Use the `.buttonTracking()` modifier:

```swift
Button("Add to Cart") {
    // Your action
}
.buttonTracking(
    buttonName: "add_to_cart_button",
    screenName: "ProductDetail",
    additionalData: ["product_id": "123"]
)
```

### 4. Track Product Interactions

```swift
Button("Add to Cart") {
    // Your action
}
.trackProductInteraction(
    action: .addToCart,
    productId: "123",
    productName: "iPhone 15 Pro",
    additionalData: ["quantity": "1"]
)
```

### 5. Track Navigation

```swift
TabView(selection: $selectedTab) {
    ProductListView()
        .tabItem { /* ... */ }
        .tag(0)
        .trackScreen("ProductList")
    
    SettingsView()
        .tabItem { /* ... */ }
        .tag(1)
        .trackScreen("Settings")
}
.onChange(of: selectedTab) { oldValue, newValue in
    let tabNames = ["Products", "Settings"]
    TelemetryService.shared.logNavigation(
        from: tabNames[safe: oldValue],
        to: tabNames[safe: newValue] ?? "Unknown",
        method: .tab
    )
}
```

## API Reference

### TelemetryService

The main service class for tracking telemetry data.

#### Configuration

```swift
TelemetryService.shared.configure(
    endpointURL: URL,           // OTLP endpoint URL
    apiKey: String?,            // Optional API key for authentication
    serviceName: String,        // Name of your service/app
    serviceVersion: String,     // Version of your service/app
    enabled: Bool               // Whether telemetry is enabled
)
```

#### Screen Tracking

```swift
// Track when a screen appears
TelemetryService.shared.logScreenAppeared("ScreenName")
```

#### Navigation Tracking

```swift
// Track navigation between screens
TelemetryService.shared.logNavigation(
    from: "SourceScreen",
    to: "DestinationScreen",
    method: .tab  // .tab, .push, .modal, .back, .deepLink
)
```

#### Button Tracking

```swift
// Track button taps
TelemetryService.shared.logButtonTap(
    buttonName: "button_identifier",
    screenName: "ScreenName",
    additionalData: ["key": "value"]
)
```

#### Product Interaction Tracking

```swift
// Track product-related actions
TelemetryService.shared.logProductInteraction(
    action: .addToCart,  // .view, .addToCart, .removeFromCart, .favorite, .unfavorite, .purchase
    productId: "123",
    productName: "Product Name",
    additionalData: ["quantity": "1"]
)
```

#### Custom Event Tracking

```swift
// Track custom events
TelemetryService.shared.logCustomEvent(
    "event_name",
    attributes: ["key": "value"]
)
```

### SwiftUI Extensions

#### View Modifiers

```swift
// Screen tracking
.trackScreen("ScreenName")

// Button tracking
.buttonTracking(
    buttonName: "button_name",
    screenName: "screen_name",
    additionalData: ["key": "value"]
)

// Product interaction tracking
.trackProductInteraction(
    action: .addToCart,
    productId: "123",
    productName: "Product Name",
    additionalData: ["key": "value"]
)

// Custom event tracking
.trackCustomEvent("event_name", attributes: ["key": "value"])
```

#### Button with Telemetry

```swift
Button.withTelemetry(
    buttonName: "button_name",
    screenName: "screen_name",
    additionalData: ["key": "value"]
) {
    // Your action
} label: {
    Text("Button Label")
}
```

#### NavigationLink with Telemetry

```swift
NavigationLink.withTelemetry(
    fromScreen: "SourceScreen",
    toScreen: "DestinationScreen",
    method: .push
) {
    DestinationView()
} label: {
    Text("Navigate")
}
```

## Data Format

The library sends data in OTLP (OpenTelemetry Protocol) format. Each event includes:

- **Trace ID**: Unique identifier for the trace
- **Span ID**: Unique identifier for the span
- **Event Name**: Name of the event (e.g., "screen_appeared", "button_tap")
- **Attributes**: Key-value pairs with event data
- **Timestamp**: ISO8601 formatted timestamp
- **Session ID**: Unique session identifier
- **Resource Attributes**: Service name, version, etc.

### Example OTLP Payload

```json
{
  "resourceSpans": [
    {
      "resource": {
        "attributes": [
          {"key": "service.name", "value": {"stringValue": "MyApp"}},
          {"key": "service.version", "value": {"stringValue": "1.0.0"}},
          {"key": "session.id", "value": {"stringValue": "uuid-here"}}
        ]
      },
      "scopeSpans": [
        {
          "spans": [
            {
              "traceId": "trace-id-bytes",
              "spanId": "span-id-bytes",
              "name": "button_tap",
              "startTimeUnixNano": 1234567890,
              "endTimeUnixNano": 1234567890,
              "attributes": [
                {"key": "button_name", "value": {"stringValue": "add_to_cart"}},
                {"key": "screen_name", "value": {"stringValue": "ProductDetail"}},
                {"key": "timestamp", "value": {"stringValue": "2024-01-01T12:00:00Z"}}
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## Sample App

The repository includes a complete sample app demonstrating all features:

- `SampleApp/` - Complete sample application
- `SampleApp/ContentView.swift` - Main tab view with navigation tracking
- `SampleApp/ProductListView.swift` - Product list with item tracking
- `SampleApp/ProductDetailView.swift` - Product detail with interaction tracking
- `SampleApp/SettingsView.swift` - Settings with toggle tracking

## Configuration Options

### Endpoint Configuration

```swift
// Basic configuration
TelemetryService.shared.configure(
    endpointURL: URL(string: "https://your-endpoint.com/v1/traces")!
)

// With authentication
TelemetryService.shared.configure(
    endpointURL: URL(string: "https://your-endpoint.com/v1/traces")!,
    apiKey: "your-api-key"
)

// Full configuration
TelemetryService.shared.configure(
    endpointURL: URL(string: "https://your-endpoint.com/v1/traces")!,
    apiKey: "your-api-key",
    serviceName: "MyApp",
    serviceVersion: "1.0.0",
    enabled: true
)
```

### Disabling Telemetry

```swift
// Disable telemetry
TelemetryService.shared.configure(
    endpointURL: URL(string: "https://your-endpoint.com/v1/traces")!,
    enabled: false
)
```

## Best Practices

1. **Consistent Naming**: Use consistent naming conventions for screen names, button names, and event names
2. **Meaningful Data**: Include relevant context in additional data
3. **Privacy**: Don't track personally identifiable information
4. **Performance**: The library sends data asynchronously to avoid blocking the UI
5. **Error Handling**: The library logs errors but doesn't crash the app

## Requirements

- iOS 14.0+
- macOS 11.0+
- tvOS 14.0+
- watchOS 7.0+
- Swift 5.9+

## Dependencies

- SwiftProtobuf: For OTLP protocol buffer serialization
- SwiftLog: For internal logging

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Support

For support and questions, please open an issue on GitHub or contact the maintainers.