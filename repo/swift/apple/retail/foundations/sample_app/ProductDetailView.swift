import SwiftUI
import TelemetryKit

struct ProductDetailView: View {
    let product: Product
    @State private var quantity = 1
    @State private var isFavorite = false
    @State private var showingAddToCart = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product Image
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
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
                                .font(.title2)
                        }
                        .buttonTracking(
                            buttonName: "favorite_button",
                            screenName: "ProductDetail",
                            additionalData: ["product_id": product.id]
                        )
                    }
                    
                    // Price
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    // Description
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Quantity Selector
                    HStack {
                        Text("Quantity:")
                            .font(.headline)
                        
                        Stepper(value: $quantity, in: 1...10) {
                            Text("\(quantity)")
                                .font(.headline)
                                .frame(minWidth: 40)
                        }
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
                    }
                    .padding(.vertical)
                    
                    // Add to Cart Button
                    Button(action: {
                        showingAddToCart = true
                        TelemetryService.shared.logProductInteraction(
                            action: .addToCart,
                            productId: product.id,
                            productName: product.name,
                            additionalData: ["quantity": String(quantity)]
                        )
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
                    .buttonTracking(
                        buttonName: "add_to_cart_button",
                        screenName: "ProductDetail",
                        additionalData: [
                            "product_id": product.id,
                            "quantity": String(quantity)
                        ]
                    )
                    
                    // Buy Now Button
                    Button(action: {
                        TelemetryService.shared.logProductInteraction(
                            action: .purchase,
                            productId: product.id,
                            productName: product.name,
                            additionalData: ["quantity": String(quantity)]
                        )
                    }) {
                        HStack {
                            Image(systemName: "creditcard")
                            Text("Buy Now")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .buttonTracking(
                        buttonName: "buy_now_button",
                        screenName: "ProductDetail",
                        additionalData: [
                            "product_id": product.id,
                            "quantity": String(quantity)
                        ]
                    )
                }
                .padding()
            }
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .trackScreen("ProductDetail")
        .alert("Added to Cart", isPresented: $showingAddToCart) {
            Button("OK") { }
        } message: {
            Text("\(product.name) has been added to your cart.")
        }
    }
}

// MARK: - Product Model
struct Product {
    let id: String
    let name: String
    let description: String
    let price: Double
    let category: String
    let imageURL: String
}

#Preview {
    NavigationView {
        ProductDetailView(product: Product(
            id: "1",
            name: "Sample Product",
            description: "This is a sample product description.",
            price: 29.99,
            category: "Electronics",
            imageURL: "https://example.com/image.jpg"
        ))
    }
}