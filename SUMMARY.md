# TelemetryKit - Complete Swift Library for OTLP Telemetry

## What We've Built

I've created a comprehensive Swift library called **TelemetryKit** that sends user interaction log events in OTLP (OpenTelemetry Protocol) format to your metrics endpoint. This library is specifically designed to work with your Swift sample app and provides easy-to-use tracking for all user interactions.

## Library Structure

```
TelemetryKit/
├── Package.swift                    # Swift Package Manager manifest
├── Sources/TelemetryKit/
│   ├── TelemetryService.swift      # Main telemetry service
│   ├── OTLPModels.swift            # OTLP protocol buffer models
│   └── SwiftUIExtensions.swift     # SwiftUI extensions and modifiers
├── Tests/TelemetryKitTests/
│   └── TelemetryServiceTests.swift # Unit tests
├── SampleApp/                      # Complete sample application
│   ├── SampleApp.swift             # App entry point with configuration
│   ├── ContentView.swift           # Main tab view
│   ├── ProductListView.swift       # Product list with tracking
│   ├── ProductDetailView.swift     # Product detail with interactions
│   └── SettingsView.swift          # Settings with toggles
├── README.md                       # Comprehensive documentation
├── IntegrationExample.md           # Step-by-step integration guide
└── SUMMARY.md                      # This summary
```

## Key Features

### 1. **OTLP Format Support**
- Sends data in OpenTelemetry Protocol format
- Includes trace IDs, span IDs, and proper resource attributes
- Supports protocol buffer serialization

### 2. **Comprehensive Tracking**
- **Screen Tracking**: `.trackScreen("ScreenName")`
- **Navigation Tracking**: Tab, push, modal, back navigation
- **Button Tracking**: `.buttonTracking(buttonName: "add_to_cart")`
- **Product Interactions**: View, add to cart, favorite, purchase
- **Custom Events**: Any custom events with attributes

### 3. **SwiftUI Integration**
- Easy-to-use view modifiers
- Automatic tracking with minimal code changes
- Built-in extensions for common UI components

### 4. **Configurable**
- Customizable endpoint URL
- Optional API key authentication
- Service name and version tracking
- Enable/disable functionality

## How to Use with Your Sample App

### 1. **Configure the Service**

Replace your current `TelemetryService.shared.logNavigation()` calls with the new library:

```swift
// In your App.swift or main entry point
import TelemetryKit

@main
struct YourApp: App {
    init() {
        TelemetryService.shared.configure(
            endpointURL: URL(string: "https://your-otlp-endpoint.com/v1/traces")!,
            apiKey: "your-api-key-here",
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

### 2. **Update Your ContentView**

Your existing ContentView can be updated to use the new tracking:

```swift
import SwiftUI
import TelemetryKit

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProductListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Products")
                }
                .tag(0)
                .trackScreen("ProductList")  // New: Automatic screen tracking

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(1)
                .trackScreen("Settings")  // New: Automatic screen tracking
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            let tabNames = ["Products", "Settings"]
            TelemetryService.shared.logNavigation(
                from: tabNames[safe: oldValue],
                to: tabNames[safe: newValue] ?? "Unknown",
                method: .tab
            )
        }
        .onAppear {
            TelemetryService.shared.logScreenAppeared("MainTabView")
        }
    }
}
```

### 3. **Add Product Interaction Tracking**

For your ProductDetailView, add comprehensive tracking:

```swift
struct ProductDetailView: View {
    let product: Product
    @State private var quantity = 1
    @State private var isFavorite = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product Image with view tracking
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(height: 300)
                .cornerRadius(12)
                .trackProductInteraction(  // New: Product view tracking
                    action: .view,
                    productId: product.id,
                    productName: product.name
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    // Product Info
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(product.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Favorite button with tracking
                        Button(action: {
                            isFavorite.toggle()
                            TelemetryService.shared.logProductInteraction(
                                action: isFavorite ? .favorite : .unfavorite,
                                productId: product.id,
                                productName: product.name
                            )
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                                .font(.title2)
                        }
                        .buttonTracking(  // New: Button tracking
                            buttonName: "favorite_button",
                            screenName: "ProductDetail",
                            additionalData: ["product_id": product.id]
                        )
                    }
                    
                    // Add to Cart Button with tracking
                    Button(action: {
                        // Your add to cart logic
                    }) {
                        HStack {
                            Image(systemName: "cart.badge.plus")
                            Text("Add to Cart")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .trackProductInteraction(  // New: Product action tracking
                        action: .addToCart,
                        productId: product.id,
                        productName: product.name,
                        additionalData: ["quantity": String(quantity)]
                    )
                }
                .padding()
            }
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .trackScreen("ProductDetail")  // New: Screen tracking
    }
}
```

## OTLP Data Format

The library sends data in proper OTLP format:

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
                {"key": "product_id", "value": {"stringValue": "123"}},
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

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/TelemetryKit.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter repository URL
3. Select version
4. Add to target

## Benefits

1. **Easy Integration**: Simple view modifiers and extensions
2. **Comprehensive Tracking**: Covers all user interactions
3. **OTLP Compliant**: Proper OpenTelemetry Protocol format
4. **Performance Optimized**: Asynchronous data sending
5. **Error Resilient**: Won't crash your app
6. **Configurable**: Customize endpoint, authentication, etc.
7. **Well Documented**: Complete examples and guides

## Next Steps

1. **Add the library** to your project using Swift Package Manager
2. **Configure the service** in your app's main entry point
3. **Replace existing tracking** calls with the new library methods
4. **Add view modifiers** to your SwiftUI views for automatic tracking
5. **Test the integration** by monitoring network requests to your OTLP endpoint

The library is designed to be a drop-in replacement for your current telemetry implementation while providing much more comprehensive tracking capabilities and proper OTLP format support.