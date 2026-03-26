import Foundation

/// R16: Subscription tiers for Zones
public enum ZonesSubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case pro = "pro"
    case household = "household"
    case enterprise = "enterprise"
    
    public var displayName: String {
        switch self { case .free: return "Free"; case .pro: return "Zones Pro"; case .household: return "Zones Household"; case .enterprise: return "Zones Enterprise" }
    }
    public var monthlyPrice: Decimal? {
        switch self { case .free: return nil; case .pro: return 3.99; case .household: return 6.99; case .enterprise: return nil }
    }
    public var maxZones: Int? {
        switch self { case .free: return 2; case .pro: return 10; case .household: return 20; case .enterprise: return nil }
    }
    public var supportsWeatherInsights: Bool { self != .free }
    public var supportsWidgets: Bool { self != .free }
    public var supportsShortcuts: Bool { self != .free }
    public var supportsTeamSharing: Bool { self == .household || self == .enterprise }
    public var supportsMDM: Bool { self == .enterprise }
    public var supportsSSO: Bool { self == .enterprise }
    public var trialDays: Int { self == .free ? 0 : 14 }
}

public struct ZonesSubscription: Codable {
    public let tier: ZonesSubscriptionTier
    public let status: String
    public let expiresAt: Date?
    public init(tier: ZonesSubscriptionTier, status: String = "active", expiresAt: Date? = nil) {
        self.tier = tier; self.status = status; self.expiresAt = expiresAt
    }
}
