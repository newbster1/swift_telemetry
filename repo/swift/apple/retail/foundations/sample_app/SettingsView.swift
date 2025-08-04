import SwiftUI
import TelemetryKit

struct SettingsView: View {
    @State private var isTelemetryEnabled = true
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedLanguage = "English"
    
    let languages = ["English", "Spanish", "French", "German"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Telemetry")) {
                    Toggle("Enable Telemetry", isOn: $isTelemetryEnabled)
                        .onChange(of: isTelemetryEnabled) { _, newValue in
                            TelemetryService.shared.logCustomEvent(
                                "telemetry_toggle_changed",
                                attributes: ["enabled": String(newValue)]
                            )
                        }
                    
                    Button("View Privacy Policy") {
                        TelemetryService.shared.logButtonTap(
                            buttonName: "privacy_policy_button",
                            screenName: "Settings"
                        )
                    }
                    .buttonTracking(
                        buttonName: "privacy_policy_button",
                        screenName: "Settings"
                    )
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            TelemetryService.shared.logCustomEvent(
                                "notifications_toggle_changed",
                                attributes: ["enabled": String(newValue)]
                            )
                        }
                    
                    Button("Notification Settings") {
                        TelemetryService.shared.logButtonTap(
                            buttonName: "notification_settings_button",
                            screenName: "Settings"
                        )
                    }
                    .buttonTracking(
                        buttonName: "notification_settings_button",
                        screenName: "Settings"
                    )
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .onChange(of: darkModeEnabled) { _, newValue in
                            TelemetryService.shared.logCustomEvent(
                                "dark_mode_toggle_changed",
                                attributes: ["enabled": String(newValue)]
                            )
                        }
                }
                
                Section(header: Text("Language")) {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    .onChange(of: selectedLanguage) { _, newValue in
                        TelemetryService.shared.logCustomEvent(
                            "language_changed",
                            attributes: ["new_language": newValue]
                        )
                    }
                }
                
                Section(header: Text("About")) {
                    Button("App Version") {
                        TelemetryService.shared.logButtonTap(
                            buttonName: "app_version_button",
                            screenName: "Settings"
                        )
                    }
                    .buttonTracking(
                        buttonName: "app_version_button",
                        screenName: "Settings"
                    )
                    
                    Button("Terms of Service") {
                        TelemetryService.shared.logButtonTap(
                            buttonName: "terms_of_service_button",
                            screenName: "Settings"
                        )
                    }
                    .buttonTracking(
                        buttonName: "terms_of_service_button",
                        screenName: "Settings"
                    )
                }
                
                Section {
                    Button("Clear All Data") {
                        TelemetryService.shared.logButtonTap(
                            buttonName: "clear_data_button",
                            screenName: "Settings"
                        )
                    }
                    .foregroundColor(.red)
                    .buttonTracking(
                        buttonName: "clear_data_button",
                        screenName: "Settings"
                    )
                }
            }
            .navigationTitle("Settings")
            .trackScreen("Settings")
        }
    }
}

#Preview {
    SettingsView()
}