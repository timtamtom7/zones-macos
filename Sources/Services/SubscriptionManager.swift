import Foundation
import StoreKit

/// R16: Subscription management for Zones
@available(macOS 13.0, *)
public final class ZonesSubscriptionManager: ObservableObject {
    public static let shared = ZonesSubscriptionManager()
    @Published public private(set) var subscription: ZonesSubscription?
    @Published public private(set) var products: [Product] = []
    
    private init() {}
    
    public func loadProducts() async {
        do {
            products = try await Product.products(for: [
                "com.zones.macos.pro.monthly",
                "com.zones.macos.pro.yearly",
                "com.zones.macos.household.monthly",
                "com.zones.macos.household.yearly"
            ])
        } catch { print("Failed to load products") }
    }
    
    public func canAccess(_ feature: ZonesFeature) -> Bool {
        guard let sub = subscription else { return false }
        switch feature {
        case .weatherInsights: return sub.tier != .free
        case .widgets: return sub.tier != .free
        case .shortcuts: return sub.tier != .free
        case .teamSharing: return sub.tier == .household || sub.tier == .enterprise
        case .mdm: return sub.tier == .enterprise
        case .sso: return sub.tier == .enterprise
        }
    }
    
    public func updateStatus() async {
        var found: ZonesSubscription = ZonesSubscription(tier: .free)
        for await result in Transaction.currentEntitlements {
            do {
                let t = try checkVerified(result)
                if t.productID.contains("household") {
                    found = ZonesSubscription(tier: .household, status: t.revocationDate == nil ? "active" : "expired")
                } else if t.productID.contains("pro") {
                    found = ZonesSubscription(tier: .pro, status: t.revocationDate == nil ? "active" : "expired")
                }
            } catch { continue }
        }
        await MainActor.run { self.subscription = found }
    }
    
    public func restore() async throws {
        try await AppStore.sync()
        await updateStatus()
    }
    
    private func checkVerified<T>(_ r: VerificationResult<T>) throws -> T {
        switch r { case .unverified: throw NSError(domain: "Zones", code: -1); case .verified(let s): return s }
    }
}

public enum ZonesFeature { case weatherInsights, widgets, shortcuts, teamSharing, mdm, sso }
