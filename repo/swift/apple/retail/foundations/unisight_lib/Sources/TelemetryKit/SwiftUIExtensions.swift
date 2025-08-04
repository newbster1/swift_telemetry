import SwiftUI

// MARK: - View Extensions for Telemetry

public extension View {
    /// Track when this view appears on screen
    /// - Parameter screenName: Name of the screen to track
    /// - Returns: Modified view with screen tracking
    func trackScreen(_ screenName: String) -> some View {
        self.onAppear {
            TelemetryService.shared.logScreenAppeared(screenName)
        }
    }
    
    /// Track button tap events
    /// - Parameters:
    ///   - buttonName: Name/identifier of the button
    ///   - screenName: Optional screen name where the button is located
    ///   - additionalData: Any additional data to include
    /// - Returns: Modified view with button tracking
    func trackButtonTap(
        buttonName: String,
        screenName: String? = nil,
        additionalData: [String: String] = [:]
    ) -> some View {
        self.onTapGesture {
            TelemetryService.shared.logButtonTap(
                buttonName: buttonName,
                screenName: screenName,
                additionalData: additionalData
            )
        }
    }
    
    /// Track product interactions
    /// - Parameters:
    ///   - action: Type of product action
    ///   - productId: Product identifier
    ///   - productName: Product name
    ///   - additionalData: Any additional data
    /// - Returns: Modified view with product interaction tracking
    func trackProductInteraction(
        action: ProductAction,
        productId: String,
        productName: String,
        additionalData: [String: String] = [:]
    ) -> some View {
        self.onTapGesture {
            TelemetryService.shared.logProductInteraction(
                action: action,
                productId: productId,
                productName: productName,
                additionalData: additionalData
            )
        }
    }
    
    /// Track custom events
    /// - Parameters:
    ///   - eventName: Name of the event
    ///   - attributes: Event attributes
    /// - Returns: Modified view with custom event tracking
    func trackCustomEvent(_ eventName: String, attributes: [String: String] = [:]) -> some View {
        self.onTapGesture {
            TelemetryService.shared.logCustomEvent(eventName, attributes: attributes)
        }
    }
}

// MARK: - Button Extensions

public extension Button {
    /// Create a button with telemetry tracking
    /// - Parameters:
    ///   - buttonName: Name/identifier of the button
    ///   - screenName: Optional screen name where the button is located
    ///   - additionalData: Any additional data to include
    ///   - action: Button action
    ///   - label: Button label
    /// - Returns: Button with telemetry tracking
    static func withTelemetry<Label: View>(
        buttonName: String,
        screenName: String? = nil,
        additionalData: [String: String] = [:],
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) -> Button<Label> {
        Button(action: {
            TelemetryService.shared.logButtonTap(
                buttonName: buttonName,
                screenName: screenName,
                additionalData: additionalData
            )
            action()
        }, label: label)
    }
}

// MARK: - Navigation Extensions

public extension NavigationLink {
    /// Create a navigation link with telemetry tracking
    /// - Parameters:
    ///   - fromScreen: Source screen name
    ///   - toScreen: Destination screen name
    ///   - method: Navigation method
    ///   - destination: Destination view
    ///   - label: Navigation link label
    /// - Returns: NavigationLink with telemetry tracking
    static func withTelemetry<Destination: View, Label: View>(
        fromScreen: String,
        toScreen: String,
        method: NavigationMethod = .push,
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label
    ) -> NavigationLink<Label, Destination> {
        NavigationLink(destination: destination().trackScreen(toScreen), label: label)
            .onTapGesture {
                TelemetryService.shared.logNavigation(
                    from: fromScreen,
                    to: toScreen,
                    method: method
                )
            }
    }
}

// MARK: - TabView Extensions

public extension TabView {
    /// Create a TabView with telemetry tracking for tab changes
    /// - Parameters:
    ///   - selection: Binding to track selected tab
    ///   - tabNames: Array of tab names for tracking
    ///   - content: TabView content
    /// - Returns: TabView with telemetry tracking
    static func withTelemetry<SelectionValue: Hashable, Content: View>(
        selection: Binding<SelectionValue>,
        tabNames: [String],
        @ViewBuilder content: () -> Content
    ) -> TabView<Content> {
        TabView(selection: selection, content: content)
            .onChange(of: selection.wrappedValue) { oldValue, newValue in
                if let oldIndex = tabNames.indices.first(where: { tabNames[$0] == String(describing: oldValue) }),
                   let newIndex = tabNames.indices.first(where: { tabNames[$0] == String(describing: newValue) }) {
                    TelemetryService.shared.logNavigation(
                        from: tabNames[safe: oldIndex],
                        to: tabNames[safe: newIndex] ?? "Unknown",
                        method: .tab
                    )
                }
            }
    }
}

// MARK: - Array Extension for Safe Access

public extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - View Modifiers

/// View modifier for tracking screen appearances
public struct ScreenTrackingModifier: ViewModifier {
    let screenName: String
    
    public init(screenName: String) {
        self.screenName = screenName
    }
    
    public func body(content: Content) -> some View {
        content.onAppear {
            TelemetryService.shared.logScreenAppeared(screenName)
        }
    }
}

/// View modifier for tracking button taps
public struct ButtonTrackingModifier: ViewModifier {
    let buttonName: String
    let screenName: String?
    let additionalData: [String: String]
    
    public init(buttonName: String, screenName: String? = nil, additionalData: [String: String] = [:]) {
        self.buttonName = buttonName
        self.screenName = screenName
        self.additionalData = additionalData
    }
    
    public func body(content: Content) -> some View {
        content.onTapGesture {
            TelemetryService.shared.logButtonTap(
                buttonName: buttonName,
                screenName: screenName,
                additionalData: additionalData
            )
        }
    }
}

/// View modifier for tracking product interactions
public struct ProductTrackingModifier: ViewModifier {
    let action: ProductAction
    let productId: String
    let productName: String
    let additionalData: [String: String]
    
    public init(action: ProductAction, productId: String, productName: String, additionalData: [String: String] = [:]) {
        self.action = action
        self.productId = productId
        self.productName = productName
        self.additionalData = additionalData
    }
    
    public func body(content: Content) -> some View {
        content.onTapGesture {
            TelemetryService.shared.logProductInteraction(
                action: action,
                productId: productId,
                productName: productName,
                additionalData: additionalData
            )
        }
    }
}

// MARK: - Custom View Modifiers

public extension View {
    /// Apply screen tracking modifier
    /// - Parameter screenName: Name of the screen
    /// - Returns: Modified view with screen tracking
    func screenTracking(_ screenName: String) -> some View {
        modifier(ScreenTrackingModifier(screenName: screenName))
    }
    
    /// Apply button tracking modifier
    /// - Parameters:
    ///   - buttonName: Name of the button
    ///   - screenName: Optional screen name
    ///   - additionalData: Additional data
    /// - Returns: Modified view with button tracking
    func buttonTracking(
        buttonName: String,
        screenName: String? = nil,
        additionalData: [String: String] = [:]
    ) -> some View {
        modifier(ButtonTrackingModifier(
            buttonName: buttonName,
            screenName: screenName,
            additionalData: additionalData
        ))
    }
    
    /// Apply product tracking modifier
    /// - Parameters:
    ///   - action: Product action
    ///   - productId: Product ID
    ///   - productName: Product name
    ///   - additionalData: Additional data
    /// - Returns: Modified view with product tracking
    func productTracking(
        action: ProductAction,
        productId: String,
        productName: String,
        additionalData: [String: String] = [:]
    ) -> some View {
        modifier(ProductTrackingModifier(
            action: action,
            productId: productId,
            productName: productName,
            additionalData: additionalData
        ))
    }
}