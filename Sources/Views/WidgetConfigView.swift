import SwiftUI

struct WidgetConfigView: View {
    @State private var showDST = true
    @State private var selectedFormat: TimeFormatOption = .twelveHour
    
    enum TimeFormatOption: String, CaseIterable {
        case twelveHour = "12h"
        case twentyFourHour = "24h"
        
        var displayName: String {
            switch self {
            case .twelveHour: return "12-hour"
            case .twentyFourHour: return "24-hour"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Widget Configuration")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Toggle("Show DST Indicators", isOn: $showDST)
                .accessibilityLabel("Show DST indicators")
                .accessibilityHint("When enabled, shows daylight saving time indicators in the widget")
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Time Format")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Picker("Time Format", selection: $selectedFormat) {
                    ForEach(TimeFormatOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Time format")
                .accessibilityHint("Select 12-hour or 24-hour time format for the widget")
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Save") {
                    saveWidgetConfig()
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Save widget configuration")
                .accessibilityHint("Saves the current widget settings and refreshes the widget")
            }
        }
        .padding(16)
        .frame(width: 300, height: 200)
    }
    
    private func saveWidgetConfig() {
        UserDefaults.standard.set(showDST, forKey: "widgetShowDST")
        UserDefaults.standard.set(selectedFormat == .twelveHour ? "12h" : "24h", forKey: "widgetTimeFormat")
        WidgetRefreshService.shared.reloadWidgets()
    }
}

struct ICloudSyncSettingsView: View {
    @State private var isSyncEnabled = iCloudSyncService.shared.isEnabled
    @State private var syncStatus: iCloudSyncService.SyncStatus = .idle
    @State private var lastSyncDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("iCloud Sync")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Toggle("Enable iCloud Sync", isOn: $isSyncEnabled)
                .accessibilityLabel("Enable iCloud sync")
                .accessibilityHint("When enabled, your zones data will sync across devices via iCloud")
                .onChange(of: isSyncEnabled) { newValue in
                    iCloudSyncService.shared.setSyncEnabled(newValue)
                }
            
            HStack {
                Text("Status:")
                    .foregroundStyle(.secondary)
                statusView
            }
            
            if let lastSync = iCloudSyncService.shared.lastSyncDate {
                Text("Last synced: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Sync Now") {
                    iCloudSyncService.shared.syncAll()
                }
                .buttonStyle(.bordered)
                .disabled(syncStatus == .syncing)
                .accessibilityLabel("Sync now")
                .accessibilityHint("Manually triggers an immediate sync of your zones data to iCloud")
            }
        }
        .padding(16)
        .frame(width: 300, height: 220)
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch syncStatus {
        case .idle:
            Text("Ready")
                .foregroundStyle(.secondary)
        case .syncing:
            ProgressView()
                .scaleEffect(0.5)
                .frame(width: 16, height: 16)
            Text("Syncing...")
                .foregroundStyle(.secondary)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Synced")
                .foregroundStyle(.green)
        case .error(let message):
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .foregroundStyle(.orange)
                .lineLimit(1)
        }
    }
}
