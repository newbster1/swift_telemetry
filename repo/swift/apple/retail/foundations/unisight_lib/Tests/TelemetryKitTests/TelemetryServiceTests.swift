import XCTest
import TelemetryKit
@testable import TelemetryKit

final class TelemetryServiceTests: XCTestCase {
    
    var telemetryService: TelemetryService!
    
    override func setUp() {
        super.setUp()
        telemetryService = TelemetryService.shared
    }
    
    override func tearDown() {
        telemetryService = nil
        super.tearDown()
    }
    
    func testConfiguration() {
        let endpointURL = URL(string: "https://test-endpoint.com/v1/traces")!
        
        telemetryService.configure(
            endpointURL: endpointURL,
            apiKey: "test-api-key",
            serviceName: "TestApp",
            serviceVersion: "1.0.0",
            enabled: true
        )
        
        // Test that configuration doesn't crash
        XCTAssertTrue(true)
    }
    
    func testScreenTracking() {
        // Test that screen tracking doesn't crash when not configured
        telemetryService.logScreenAppeared("TestScreen")
        XCTAssertTrue(true)
    }
    
    func testNavigationTracking() {
        // Test that navigation tracking doesn't crash when not configured
        telemetryService.logNavigation(
            from: "SourceScreen",
            to: "DestinationScreen",
            method: .tab
        )
        XCTAssertTrue(true)
    }
    
    func testButtonTracking() {
        // Test that button tracking doesn't crash when not configured
        telemetryService.logButtonTap(
            buttonName: "test_button",
            screenName: "TestScreen",
            additionalData: ["key": "value"]
        )
        XCTAssertTrue(true)
    }
    
    func testProductInteractionTracking() {
        // Test that product interaction tracking doesn't crash when not configured
        telemetryService.logProductInteraction(
            action: .addToCart,
            productId: "123",
            productName: "Test Product",
            additionalData: ["quantity": "1"]
        )
        XCTAssertTrue(true)
    }
    
    func testCustomEventTracking() {
        // Test that custom event tracking doesn't crash when not configured
        telemetryService.logCustomEvent(
            "test_event",
            attributes: ["key": "value"]
        )
        XCTAssertTrue(true)
    }
    
    func testNavigationMethodEnum() {
        // Test all navigation methods
        let methods: [NavigationMethod] = [.tab, .push, .modal, .back, .deepLink]
        
        for method in methods {
            XCTAssertFalse(method.rawValue.isEmpty)
        }
    }
    
    func testProductActionEnum() {
        // Test all product actions
        let actions: [ProductAction] = [.view, .addToCart, .removeFromCart, .favorite, .unfavorite, .purchase]
        
        for action in actions {
            XCTAssertFalse(action.rawValue.isEmpty)
        }
    }
    
    func testTelemetryEventCreation() {
        let event = TelemetryEvent(
            name: "test_event",
            attributes: ["key": "value"]
        )
        
        XCTAssertEqual(event.name, "test_event")
        XCTAssertEqual(event.attributes["key"], "value")
    }
    
    func testArraySafeAccess() {
        let array = ["a", "b", "c"]
        
        XCTAssertEqual(array[safe: 0], "a")
        XCTAssertEqual(array[safe: 1], "b")
        XCTAssertEqual(array[safe: 2], "c")
        XCTAssertNil(array[safe: 3])
        XCTAssertNil(array[safe: -1])
    }
}