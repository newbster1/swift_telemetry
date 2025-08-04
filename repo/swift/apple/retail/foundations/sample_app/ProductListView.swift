import SwiftUI
import TelemetryKit

struct ProductListView: View {
    @State private var products: [Product] = [
        Product(
            id: "1",
            name: "iPhone 15 Pro",
            description: "Latest iPhone with advanced features",
            price: 999.99,
            category: "Electronics",
            imageURL: "https://example.com/iphone.jpg"
        ),
        Product(
            id: "2",
            name: "MacBook Air",
            description: "Lightweight laptop for everyday use",
            price: 1199.99,
            category: "Electronics",
            imageURL: "https://example.com/macbook.jpg"
        ),
        Product(
            id: "3",
            name: "AirPods Pro",
            description: "Wireless earbuds with noise cancellation",
            price: 249.99,
            category: "Electronics",
            imageURL: "https://example.com/airpods.jpg"
        )
    ]
    
    var body: some View {
        NavigationView {
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
            .refreshable {
                TelemetryService.shared.logCustomEvent("product_list_refresh")
            }
        }
    }
}

struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                
                Text(product.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(action: {
                TelemetryService.shared.logProductInteraction(
                    action: .favorite,
                    productId: product.id,
                    productName: product.name
                )
            }) {
                Image(systemName: "heart")
                    .foregroundColor(.gray)
            }
            .buttonTracking(
                buttonName: "favorite_product",
                screenName: "ProductList",
                additionalData: ["product_id": product.id]
            )
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProductListView()
}