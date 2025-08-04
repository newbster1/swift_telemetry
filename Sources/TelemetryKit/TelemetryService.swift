import Foundation
import SwiftUI
import Logging

/// Main telemetry service for tracking user interactions and sending data in OTLP format
public class TelemetryService: ObservableObject {
    public static let shared = TelemetryService()
    
    private let logger = Logger(label: "TelemetryService")
    private let session = URLSession.shared
    private let queue = DispatchQueue(label: "telemetry.queue", qos: .utility)
    
    // Configuration
    private var endpointURL: URL?
    private var apiKey: String?
    private var serviceName: String = "Unknown"
    private var serviceVersion: String = "1.0.0"
    private var isEnabled: Bool = true
    
    // Session tracking
    private let sessionId = UUID().uuidString
    private let startTime = Date()
    
    private init() {}
    
    // MARK: - Configuration
    
    /// Configure the telemetry service
    /// - Parameters:
    ///   - endpointURL: The OTLP endpoint URL to send data to
    ///   - apiKey: Optional API key for authentication
    ///   - serviceName: Name of the service/app
    ///   - serviceVersion: Version of the service/app
    ///   - enabled: Whether telemetry is enabled
    public func configure(
        endpointURL: URL,
        apiKey: String? = nil,
        serviceName: String = "Unknown",
        serviceVersion: String = "1.0.0",
        enabled: Bool = true
    ) {
        self.endpointURL = endpointURL
        self.apiKey = apiKey
        self.serviceName = serviceName
        self.serviceVersion = serviceVersion
        self.isEnabled = enabled
        
        logger.info("TelemetryService configured for \(serviceName) v\(serviceVersion)")
    }
    
    // MARK: - Screen Tracking
    
    /// Log when a screen appears
    /// - Parameter screenName: Name of the screen
    public func logScreenAppeared(_ screenName: String) {
        guard isEnabled else { return }
        
        let event = TelemetryEvent(
            name: "screen_appeared",
            attributes: [
                "screen_name": screenName,
                "session_id": sessionId,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )
        
        sendEvent(event)
        logger.debug("Screen appeared: \(screenName)")
    }
    
    /// Log navigation between screens
    /// - Parameters:
    ///   - from: Source screen name
    ///   - to: Destination screen name
    ///   - method: Navigation method
    public func logNavigation(from: String?, to: String, method: NavigationMethod) {
        guard isEnabled else { return }
        
        let event = TelemetryEvent(
            name: "navigation",
            attributes: [
                "from_screen": from ?? "unknown",
                "to_screen": to,
                "navigation_method": method.rawValue,
                "session_id": sessionId,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )
        
        sendEvent(event)
        logger.debug("Navigation: \(from ?? "unknown") -> \(to) via \(method.rawValue)")
    }
    
    // MARK: - User Interaction Tracking
    
    /// Log button tap events
    /// - Parameters:
    ///   - buttonName: Name/identifier of the button
    ///   - screenName: Screen where the button was tapped
    ///   - additionalData: Any additional data to include
    public func logButtonTap(
        buttonName: String,
        screenName: String? = nil,
        additionalData: [String: String] = [:]
    ) {
        guard isEnabled else { return }
        
        var attributes: [String: String] = [
            "button_name": buttonName,
            "session_id": sessionId,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let screenName = screenName {
            attributes["screen_name"] = screenName
        }
        
        attributes.merge(additionalData) { _, new in new }
        
        let event = TelemetryEvent(name: "button_tap", attributes: attributes)
        sendEvent(event)
        logger.debug("Button tap: \(buttonName) on \(screenName ?? "unknown screen")")
    }
    
    /// Log product interactions
    /// - Parameters:
    ///   - action: Type of product action
    ///   - productId: Product identifier
    ///   - productName: Product name
    ///   - additionalData: Any additional data
    public func logProductInteraction(
        action: ProductAction,
        productId: String,
        productName: String,
        additionalData: [String: String] = [:]
    ) {
        guard isEnabled else { return }
        
        var attributes: [String: String] = [
            "action": action.rawValue,
            "product_id": productId,
            "product_name": productName,
            "session_id": sessionId,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        attributes.merge(additionalData) { _, new in new }
        
        let event = TelemetryEvent(name: "product_interaction", attributes: attributes)
        sendEvent(event)
        logger.debug("Product interaction: \(action.rawValue) for \(productName)")
    }
    
    // MARK: - Custom Events
    
    /// Log custom events
    /// - Parameters:
    ///   - eventName: Name of the event
    ///   - attributes: Event attributes
    public func logCustomEvent(_ eventName: String, attributes: [String: String] = [:]) {
        guard isEnabled else { return }
        
        var eventAttributes = attributes
        eventAttributes["session_id"] = sessionId
        eventAttributes["timestamp"] = ISO8601DateFormatter().string(from: Date())
        
        let event = TelemetryEvent(name: eventName, attributes: eventAttributes)
        sendEvent(event)
        logger.debug("Custom event: \(eventName)")
    }
    
    // MARK: - Private Methods
    
    private func sendEvent(_ event: TelemetryEvent) {
        guard let endpointURL = endpointURL else {
            logger.error("No endpoint URL configured")
            return
        }
        
        queue.async { [weak self] in
            self?.sendOTLPEvent(event, to: endpointURL)
        }
    }
    
    private func sendOTLPEvent(_ event: TelemetryEvent, to url: URL) {
        do {
            let otlpData = try createOTLPPayload(for: event)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
            
            if let apiKey = apiKey {
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            }
            
            request.httpBody = otlpData
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    self?.logger.error("Failed to send telemetry: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self?.logger.debug("Telemetry sent successfully")
                    } else {
                        self?.logger.error("Telemetry failed with status: \(httpResponse.statusCode)")
                    }
                }
            }
            
            task.resume()
            
        } catch {
            logger.error("Failed to create OTLP payload: \(error.localizedDescription)")
        }
    }
    
    private func createOTLPPayload(for event: TelemetryEvent) throws -> Data {
        // Create OTLP ExportTraceServiceRequest
        let resource = OTLPResource(
            attributes: [
                "service.name": serviceName,
                "service.version": serviceVersion,
                "session.id": sessionId
            ]
        )
        
        let span = OTLPSpan(
            traceId: generateTraceId(),
            spanId: generateSpanId(),
            name: event.name,
            startTimeUnixNano: UInt64(Date().timeIntervalSince1970 * 1_000_000_000),
            endTimeUnixNano: UInt64(Date().timeIntervalSince1970 * 1_000_000_000),
            attributes: event.attributes.map { key, value in
                OTLPKeyValue(key: key, value: OTLPAnyValue(stringValue: value))
            }
        )
        
        let scopeSpans = OTLPScopeSpans(spans: [span])
        let resourceSpans = OTLPResourceSpans(resource: resource, scopeSpans: [scopeSpans])
        let request = OTLPExportTraceServiceRequest(resourceSpans: [resourceSpans])
        
        return try request.serializedData()
    }
    
    private func generateTraceId() -> Data {
        var traceId = Data(count: 16)
        _ = traceId.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 16, bytes.baseAddress!)
        }
        return traceId
    }
    
    private func generateSpanId() -> Data {
        var spanId = Data(count: 8)
        _ = spanId.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 8, bytes.baseAddress!)
        }
        return spanId
    }
}

// MARK: - Supporting Types

public enum NavigationMethod: String, CaseIterable {
    case tab = "tab"
    case push = "push"
    case modal = "modal"
    case back = "back"
    case deepLink = "deep_link"
}

public enum ProductAction: String, CaseIterable {
    case view = "view"
    case addToCart = "add_to_cart"
    case removeFromCart = "remove_from_cart"
    case favorite = "favorite"
    case unfavorite = "unfavorite"
    case purchase = "purchase"
}

public struct TelemetryEvent {
    let name: String
    let attributes: [String: String]
    
    public init(name: String, attributes: [String: String]) {
        self.name = name
        self.attributes = attributes
    }
}