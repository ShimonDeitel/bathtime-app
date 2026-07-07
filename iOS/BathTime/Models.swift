import Foundation

struct CareEventEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var note: String
    var value: Double
    var date: Date

    init(id: UUID = UUID(), title: String, note: String = "", value: Double = 0, date: Date = Date()) {
        self.id = id
        self.title = title
        self.note = note
        self.value = value
        self.date = date
    }
}

struct AppSettings: Codable, Equatable {
    var remindersEnabled: Bool = true
    var soundEnabled: Bool = true
    var hasSeenOnboarding: Bool = false
}
