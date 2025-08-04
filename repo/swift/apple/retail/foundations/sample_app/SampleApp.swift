import SwiftUI
import TelemetryKit

@main
struct SampleApp: App {
    init() {
        // Configure the telemetry service
        TelemetryService.shared.configure(
            endpointURL: URL(string: "https://your-otlp-endpoint.com/v1/traces")!,
            apiKey: "your-api-key-here",
            serviceName: "SampleApp",
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