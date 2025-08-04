# Sample App

This is a sample SwiftUI application that demonstrates how to use the TelemetryKit library for tracking user interactions and sending telemetry data in OTLP format.

## Features

- **Product List**: Browse products with telemetry tracking
- **Product Detail**: View product details with interaction tracking
- **Settings**: Configure app settings with telemetry
- **Navigation**: Tab-based navigation with tracking
- **Comprehensive Tracking**: Demonstrates all telemetry features

## Structure

```
sample_app/
├── SampleApp.swift          # Main app entry point with telemetry configuration
├── ContentView.swift        # Main tab view with navigation tracking
├── ProductListView.swift    # Product list with item tracking
├── ProductDetailView.swift  # Product detail with interaction tracking
└── SettingsView.swift       # Settings with toggle tracking
```

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 14.0+
- Swift 5.9+

### Setup

1. **Configure Telemetry Endpoint**: Update the endpoint URL in `SampleApp.swift`:

```swift
TelemetryService.shared.configure(
    endpointURL: URL(string: "https://your-otlp-endpoint.com/v1/traces")!,
    apiKey: "your-api-key-here",
    serviceName: "SampleApp",
    serviceVersion: "1.0.0",
    enabled: true
)
```

2. **Add TelemetryKit Dependency**: Add the TelemetryKit library to your project:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/TelemetryKit.git", from: "1.0.0")
]
```

3. **Build and Run**: Build the project and run it on a simulator or device.

## Tracking Examples

### Screen Tracking

```swift
.trackScreen("ProductList")
```

### Button Tracking

```swift
.buttonTracking(
    buttonName: "add_to_cart_button",
    screenName: "ProductDetail",
    additionalData: ["product_id": product.id]
)
```

### Product Interaction Tracking

```swift
.trackProductInteraction(
    action: .addToCart,
    productId: product.id,
    productName: product.name,
    additionalData: ["quantity": String(quantity)]
)
```

### Navigation Tracking

```swift
.onChange(of: selectedTab) { oldValue, newValue in
    let tabNames = ["Products", "Settings"]
    TelemetryService.shared.logNavigation(
        from: tabNames[safe: oldValue],
        to: tabNames[safe: newValue] ?? "Unknown",
        method: .tab
    )
}
```

### Custom Event Tracking

```swift
.onChange(of: quantity) { _, newValue in
    TelemetryService.shared.logCustomEvent(
        "quantity_changed",
        attributes: [
            "product_id": product.id,
            "product_name": product.name,
            "new_quantity": String(newValue)
        ]
    )
}
```

## What Gets Tracked

### Product List Screen
- Screen appearance
- Product view interactions
- Favorite button taps
- Pull-to-refresh events

### Product Detail Screen
- Screen appearance
- Product image view interactions
- Favorite/unfavorite actions
- Quantity changes
- Add to cart actions
- Buy now actions

### Settings Screen
- Screen appearance
- Toggle changes (telemetry, notifications, dark mode)
- Language selection changes
- Button taps (privacy policy, terms, etc.)

### Navigation
- Tab changes between Products and Settings
- Navigation between screens

## Testing

To test the telemetry functionality:

1. **Network Monitoring**: Use Charles Proxy, Fiddler, or Xcode's Network tab to monitor requests
2. **Endpoint Testing**: Set up a test OTLP endpoint to receive the data
3. **Console Logs**: Check Xcode console for telemetry service logs

## Expected OTLP Data

The app will send OTLP-formatted data including:

- **Resource Attributes**: Service name, version, session ID
- **Span Data**: Event names, timestamps, attributes
- **Event Types**: screen_appeared, button_tap, product_interaction, navigation, custom events

## Customization

You can customize the sample app by:

1. **Adding More Screens**: Create new views with telemetry tracking
2. **Custom Events**: Add more custom event tracking
3. **Product Data**: Modify the product model and data
4. **UI Customization**: Update the UI design and layout

## Troubleshooting

- **No Network Requests**: Check that the endpoint URL is correct and accessible
- **Authentication Errors**: Verify your API key is valid
- **Build Errors**: Ensure TelemetryKit dependency is properly added
- **Missing Tracking**: Check that view modifiers are applied correctly

## Next Steps

After running the sample app:

1. **Integrate with Your App**: Use the patterns shown in the sample app
2. **Customize Tracking**: Add your own custom events and tracking
3. **Configure Endpoint**: Set up your production OTLP endpoint
4. **Monitor Data**: Set up monitoring and analytics for the telemetry data

## Support

For questions about the sample app or TelemetryKit integration, please refer to the main TelemetryKit documentation or open an issue on GitHub.