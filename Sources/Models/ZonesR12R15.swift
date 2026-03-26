import Foundation

// MARK: - Zones R12-R15 Models

struct ZoneTeam: Identifiable, Codable {
    let id: UUID
    var name: String
    var members: [ZoneMember]
    var sharedZones: [SharedZone]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        members: [ZoneMember] = [],
        sharedZones: [SharedZone] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.sharedZones = sharedZones
        self.createdAt = createdAt
    }
}

struct ZoneMember: Identifiable, Codable {
    let id: UUID
    var name: String
    var timezone: String
    var role: MemberRole

    enum MemberRole: String, Codable {
        case admin
        case editor
        case viewer
    }

    init(id: UUID = UUID(), name: String, timezone: String, role: MemberRole = .viewer) {
        self.id = id
        self.name = name
        self.timezone = timezone
        self.role = role
    }
}

struct SharedZone: Identifiable, Codable {
    let id: UUID
    var zoneId: UUID
    var shareCode: String
    var expiresAt: Date?

    init(
        id: UUID = UUID(),
        zoneId: UUID,
        shareCode: String = String(UUID().uuidString.prefix(8)).uppercased(),
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.zoneId = zoneId
        self.shareCode = shareCode
        self.expiresAt = expiresAt
    }
}

struct MeetingAvailability: Identifiable, Codable {
    let id: UUID
    var participants: [ParticipantTimezone]
    var suggestedSlots: [TimeSlot]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        participants: [ParticipantTimezone] = [],
        suggestedSlots: [TimeSlot] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.participants = participants
        self.suggestedSlots = suggestedSlots
        self.createdAt = createdAt
    }
}

struct ParticipantTimezone: Identifiable, Codable {
    let id: UUID
    var name: String
    var timezone: String
    var localHour: Int

    init(id: UUID = UUID(), name: String, timezone: String, localHour: Int) {
        self.id = id
        self.name = name
        self.timezone = timezone
        self.localHour = localHour
    }
}

struct TimeSlot: Identifiable, Codable {
    let id: UUID
    var startTime: Date
    var endTime: Date
    var allParticipantsAvailable: Bool

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        allParticipantsAvailable: Bool = true
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.allParticipantsAvailable = allParticipantsAvailable
    }
}
