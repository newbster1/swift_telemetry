# Integration Example

This document shows how to integrate TelemetryKit into your existing Swift app.

## Step 1: Add the Dependency

### Using Swift Package Manager

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/your-username/TelemetryKit.git`
3. Select the version you want to use
4. Add it to your target

### Using Package.swift

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/TelemetryKit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["TelemetryKit"]
    )
]
```

## Step 2: Configure the Service

In your main app file (e.g., `YourApp.swift`):

```swift
import SwiftUI
import TelemetryKit

@main
struct YourApp: App {
    init() {
        // Configure telemetry service
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

## Step 3: Add Tracking to Your Views

### Before (Original Code)

```swift
struct ProductListView: View {
    var body: some View {
        List(products) { product in
            NavigationLink(destination: ProductDetailView(product: product)) {
                ProductRowView(product: product)
            }
        }
        .navigationTitle("Products")
    }
}

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        VStack {
            Text(product.name)
            Text("$\(product.price)")
            
            Button("Add to Cart") {
                addToCart(product)
            }
        }
        .navigationTitle(product.name)
    }
}
```

### After (With Telemetry)

```swift
import TelemetryKit

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
        .navigationTitle("Products")
        .trackScreen("ProductList")
    }
}

struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        VStack {
            Text(product.name)
            Text("$\(product.price)")
            
            Button("Add to Cart") {
                addToCart(product)
            }
            .buttonTracking(
                buttonName: "add_to_cart_button",
                screenName: "ProductDetail",
                additionalData: ["product_id": product.id]
            )
        }
        .navigationTitle(product.name)
        .trackScreen("ProductDetail")
    }
}
```

## Step 4: Track Navigation

### Tab Navigation

```swift
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
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
    }
}
```

### Push Navigation

```swift
NavigationLink(destination: ProductDetailView(product: product)) {
    ProductRowView(product: product)
}
.onTapGesture {
    TelemetryService.shared.logNavigation(
        from: "ProductList",
        to: "ProductDetail",
        method: .push
    )
}
```

## Step 5: Track User Interactions

### Button Clicks

```swift
Button("Add to Cart") {
    addToCart(product)
}
.buttonTracking(
    buttonName: "add_to_cart_button",
    screenName: "ProductDetail",
    additionalData: ["product_id": product.id]
)
```

### Product Actions

```swift
Button("Add to Cart") {
    addToCart(product)
}
.trackProductInteraction(
    action: .addToCart,
    productId: product.id,
    productName: product.name,
    additionalData: ["quantity": "1"]
)
```

### Custom Events

```swift
.onChange(of: quantity) { _, newValue in
    TelemetryService.shared.logCustomEvent(
        "quantity_changed",
        attributes: [
            "product_id": product.id,
            "new_quantity": String(newValue)
        ]
    )
}
```

## Step 6: Track Settings Changes

```swift
Toggle("Dark Mode", isOn: $darkModeEnabled)
    .onChange(of: darkModeEnabled) { _, newValue in
        TelemetryService.shared.logCustomEvent(
            "dark_mode_toggle_changed",
            attributes: ["enabled": String(newValue)]
        )
    }
```

## Step 7: Track Form Submissions

```swift
Button("Submit") {
    submitForm()
}
.buttonTracking(
    buttonName: "form_submit_button",
    screenName: "ContactForm",
    additionalData: ["form_type": "contact"]
)
```

## Step 8: Track Search

```swift
TextField("Search", text: $searchText)
    .onSubmit {
        TelemetryService.shared.logCustomEvent(
            "search_performed",
            attributes: [
                "search_term": searchText,
                "screen": "ProductList"
            ]
        )
        performSearch()
    }
```

## Complete Example

Here's a complete example of a view with comprehensive tracking:

```swift
import SwiftUI
import TelemetryKit

struct ProductDetailView: View {
    let product: Product
    @State private var quantity = 1
    @State private var isFavorite = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product Image
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(height: 300)
                .cornerRadius(12)
                .trackProductInteraction(
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
                        }
                        .buttonTracking(
                            buttonName: "favorite_button",
                            screenName: "ProductDetail"
                        )
                    }
                    
                    // Price
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    // Quantity Selector
                    HStack {
                        Text("Quantity:")
                        Stepper(value: $quantity, in: 1...10) {
                            Text("\(quantity)")
                        }
                        .onChange(of: quantity) { _, newValue in
                            TelemetryService.shared.logCustomEvent(
                                "quantity_changed",
                                attributes: [
                                    "product_id": product.id,
                                    "new_quantity": String(newValue)
                                ]
                            )
                        }
                    }
                    
                    // Add to Cart Button
                    Button(action: {
                        addToCart(product, quantity: quantity)
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
                    .trackProductInteraction(
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
        .trackScreen("ProductDetail")
    }
    
    private func addToCart(_ product: Product, quantity: Int) {
        // Your add to cart logic
        print("Added \(quantity) of \(product.name) to cart")
    }
}
```

## Best Practices

1. **Consistent Naming**: Use consistent naming for screen names, button names, and events
2. **Meaningful Context**: Include relevant data in additional attributes
3. **Privacy**: Don't track personally identifiable information
4. **Performance**: The library sends data asynchronously, so it won't block your UI
5. **Error Handling**: The library handles errors gracefully and won't crash your app

## Testing

To test that telemetry is working:

1. Configure the service with a test endpoint
2. Use a tool like Charles Proxy or Fiddler to intercept network requests
3. Perform actions in your app and verify that OTLP requests are sent
4. Check the request payload to ensure data is formatted correctly

## Troubleshooting

- **No data being sent**: Check that the endpoint URL is correct and accessible
- **Authentication errors**: Verify your API key is correct
- **Malformed data**: Check that all required fields are provided
- **Performance issues**: The library sends data asynchronously, so it shouldn't impact performance