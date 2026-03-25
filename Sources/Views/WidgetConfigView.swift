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
            Text("Widget Configuration")
                .font(.headline)
            
            Toggle("Show DST Indicators", isOn: $showDST)
                .toggleStyle(.checkbox)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Time Format")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Time Format", selection: $selectedFormat) {
                    ForEach(TimeFormatOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Save") {
                    saveWidgetConfig()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
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
            Text("iCloud Sync")
                .font(.headline)
            
            Toggle("Enable iCloud Sync", isOn: $isSyncEnabled)
                .toggleStyle(.checkbox)
                .onChange(of: isSyncEnabled) { newValue in
                    iCloudSyncService.shared.setSyncEnabled(newValue)
                }
            
            HStack {
                Text("Status:")
                    .foregroundColor(.secondary)
                statusView
            }
            
            if let lastSync = iCloudSyncService.shared.lastSyncDate {
                Text("Last synced: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Sync Now") {
                    iCloudSyncService.shared.syncAll()
                }
                .buttonStyle(.bordered)
                .disabled(syncStatus == .syncing)
            }
        }
        .padding()
        .frame(width: 300, height: 220)
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch syncStatus {
        case .idle:
            Text("Ready")
                .foregroundColor(.secondary)
        case .syncing:
            ProgressView()
                .scaleEffect(0.5)
                .frame(width: 16, height: 16)
            Text("Syncing...")
                .foregroundColor(.secondary)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Synced")
                .foregroundColor(.green)
        case .error(let message):
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .foregroundColor(.orange)
                .lineLimit(1)
        }
    }
}
