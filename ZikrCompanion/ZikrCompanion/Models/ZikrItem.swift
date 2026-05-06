import Foundation

// MARK: - RoutineType

enum RoutineType: String, CaseIterable, Codable {
    case morning = "morning"
    case evening = "evening"

    var displayName: String {
        switch self {
        case .morning: return "Matin"
        case .evening: return "Soir"
        }
    }

    var arabicLabel: String {
        switch self {
        case .morning: return "الصباح"
        case .evening: return "المساء"
        }
    }

    var target: Int {
        switch self {
        case .morning: return 100
        case .evening: return 33
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sun.horizon.fill"
        case .evening: return "moon.stars.fill"
        }
    }
}

// MARK: - ZikrItem

struct ZikrItem: Identifiable, Codable {
    let id: UUID
    let arabic: String
    let transliteration: String
    let translation: String
    let routineType: RoutineType

    init(
        id: UUID = UUID(),
        arabic: String,
        transliteration: String,
        translation: String,
        routineType: RoutineType
    ) {
        self.id = id
        self.arabic = arabic
        self.transliteration = transliteration
        self.translation = translation
        self.routineType = routineType
    }
}

// MARK: - Catalogue par défaut

extension ZikrItem {
    static let morningItems: [ZikrItem] = [
        ZikrItem(
            arabic: "سُبْحَانَ اللهِ وَبِحَمْدِهِ",
            transliteration: "Subhāna-llāhi wa bi-ḥamdih",
            translation: "Gloire à Allah et Sa louange",
            routineType: .morning
        ),
        ZikrItem(
            arabic: "لَا إِلَهَ إِلَّا اللهُ",
            transliteration: "Lā ilāha illa-llāh",
            translation: "Pas de divinité sauf Allah",
            routineType: .morning
        ),
        ZikrItem(
            arabic: "اللهُ أَكْبَر",
            transliteration: "Allāhu Akbar",
            translation: "Allah est le Plus Grand",
            routineType: .morning
        )
    ]

    static let eveningItems: [ZikrItem] = [
        ZikrItem(
            arabic: "أَسْتَغْفِرُ اللهَ",
            transliteration: "Astaghfiru-llāh",
            translation: "Je demande pardon à Allah",
            routineType: .evening
        ),
        ZikrItem(
            arabic: "سُبْحَانَ اللهِ",
            transliteration: "Subhāna-llāh",
            translation: "Gloire à Allah",
            routineType: .evening
        )
    ]
}
