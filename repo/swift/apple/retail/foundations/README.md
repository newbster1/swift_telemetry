# Swift Apple Retail Foundations

This directory contains the foundational components for Swift Apple Retail applications, including a telemetry library and sample application.

## Structure

```
foundations/
├── unisight_lib/           # TelemetryKit library (OTLP telemetry)
│   ├── Package.swift       # Swift Package Manager manifest
│   ├── Sources/            # Library source code
│   ├── Tests/              # Unit tests
│   └── README.md           # Library documentation
├── sample_app/             # Sample SwiftUI application
│   ├── SampleApp.swift     # Main app entry point
│   ├── ContentView.swift   # Main tab view
│   ├── ProductListView.swift # Product list with tracking
│   ├── ProductDetailView.swift # Product detail with interactions
│   ├── SettingsView.swift  # Settings with toggles
│   └── README.md           # Sample app documentation
└── README.md               # This file
```

## Components

### Unisight Library (TelemetryKit)

A comprehensive Swift library for tracking user interactions and sending telemetry data in OTLP (OpenTelemetry Protocol) format.

**Features:**
- Screen tracking
- Navigation tracking
- Button interaction tracking
- Product interaction tracking
- Custom event tracking
- OTLP format support
- SwiftUI integration
- Configurable endpoints and authentication

**Usage:**
```swift
import TelemetryKit

// Configure the service
TelemetryService.shared.configure(
    endpointURL: URL(string: "https://your-otlp-endpoint.com/v1/traces")!,
    apiKey: "your-api-key",
    serviceName: "YourApp",
    serviceVersion: "1.0.0"
)

// Track screens
.trackScreen("ProductList")

// Track button interactions
.buttonTracking(buttonName: "add_to_cart", screenName: "ProductDetail")

// Track product interactions
.trackProductInteraction(action: .addToCart, productId: "123", productName: "iPhone")
```

### Sample App

A complete SwiftUI application that demonstrates how to use the TelemetryKit library for comprehensive user interaction tracking.

**Features:**
- Product browsing with telemetry
- Product detail views with interaction tracking
- Settings management with telemetry
- Tab-based navigation with tracking
- Comprehensive tracking examples

**Screens:**
- **Product List**: Browse products with view tracking
- **Product Detail**: View product details with interaction tracking
- **Settings**: Configure app settings with telemetry

## Getting Started

### 1. Set Up the Library

Navigate to the `unisight_lib` directory and add it as a dependency to your project:

```swift
dependencies: [
    .package(path: "path/to/unisight_lib")
]
```

### 2. Configure Telemetry

In your app's main entry point:

```swift
import TelemetryKit

@main
struct YourApp: App {
    init() {
        TelemetryService.shared.configure(
            endpointURL: URL(string: "https://your-otlp-endpoint.com/v1/traces")!,
            apiKey: "your-api-key",
            serviceName: "YourApp",
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

### 3. Add Tracking to Your Views

```swift
struct ProductListView: View {
    var body: some View {
        List(products) { product in
            NavigationLink(destination: ProductDetailView(product: product)) {
                ProductRowView(product: product)
            }
            .trackProductInteraction(
                action: .view,
                productId: product.id,
                productName: product.name
            )
        }
        .trackScreen("ProductList")
    }
}
```

### 4. Run the Sample App

Navigate to the `sample_app` directory and run the sample application to see the telemetry library in action.

## OTLP Data Format

The library sends data in OpenTelemetry Protocol format:

```json
{
  "resourceSpans": [
    {
      "resource": {
        "attributes": [
          {"key": "service.name", "value": {"stringValue": "YourApp"}},
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

## Requirements

- iOS 14.0+
- macOS 11.0+
- tvOS 14.0+
- watchOS 7.0+
- Swift 5.9+
- Xcode 15.0+

## Dependencies

- SwiftProtobuf: For OTLP protocol buffer serialization
- SwiftLog: For internal logging

## Testing

### Unit Tests

Run the unit tests for the TelemetryKit library:

```bash
cd unisight_lib
swift test
```

### Integration Testing

1. Configure the sample app with your OTLP endpoint
2. Run the sample app
3. Monitor network requests to verify telemetry data is sent
4. Check the OTLP endpoint to ensure data is received correctly

## Best Practices

1. **Consistent Naming**: Use consistent naming for screen names, button names, and events
2. **Meaningful Context**: Include relevant data in additional attributes
3. **Privacy**: Don't track personally identifiable information
4. **Performance**: The library sends data asynchronously to avoid blocking the UI
5. **Error Handling**: The library handles errors gracefully and won't crash your app

## Support

- **Library Documentation**: See `unisight_lib/README.md`
- **Sample App Documentation**: See `sample_app/README.md`
- **Integration Guide**: See the integration examples in the sample app

## License

This project is licensed under the MIT License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request