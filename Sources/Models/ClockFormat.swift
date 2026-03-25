import Foundation

enum ClockDisplayMode: String, CaseIterable, Codable {
    case digital
    case analog
    case both
}

struct ClockFormat: Codable {
    var displayMode: ClockDisplayMode
    var digitalFormat: String
    var use24Hour: Bool
    var showSeconds: Bool
    var showTimezoneAbbreviation: Bool
    var fontStyle: FontStyle

    enum FontStyle: String, CaseIterable, Codable {
        case system
        case monospaced
        case rounded

        var fontName: String? {
            switch self {
            case .system: return nil
            case .monospaced: return "Menlo"
            case .rounded: return ".AppleSystemUIFontRounded"
            }
        }
    }

    static let `default` = ClockFormat(
        displayMode: .digital,
        digitalFormat: "HH:mm",
        use24Hour: false,
        showSeconds: false,
        showTimezoneAbbreviation: false,
        fontStyle: .system
    )
}

struct CitySettings: Identifiable, Codable {
    let id: UUID
    let cityId: String
    var nickname: String?
    var clockFormat: ClockFormat
    var colorLabel: String
    var isHiddenFromMenuBar: Bool
    var updatedAt: Date

    init(id: UUID = UUID(), cityId: String, nickname: String? = nil, clockFormat: ClockFormat = .default, colorLabel: String = "#007AFF", isHiddenFromMenuBar: Bool = false, updatedAt: Date = Date()) {
        self.id = id
        self.cityId = cityId
        self.nickname = nickname
        self.clockFormat = clockFormat
        self.colorLabel = colorLabel
        self.isHiddenFromMenuBar = isHiddenFromMenuBar
        self.updatedAt = updatedAt
    }
}
