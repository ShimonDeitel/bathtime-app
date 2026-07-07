import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [CareEventEntry] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isPro: Bool = false

    /// Free tier can hold this many entries before the paywall triggers.
    /// Always kept comfortably above seed data count so a fresh install
    /// never hits the paywall immediately.
    static let freeEntryLimit = 15

    private let entriesURL: URL
    private let settingsURL: URL

    init() {
        let dir = Store.appSupportDirectory()
        entriesURL = dir.appendingPathComponent("entries.json")
        settingsURL = dir.appendingPathComponent("settings.json")
        load()
    }

    static func appSupportDirectory() -> URL {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("BathTime", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func load() {
        if let data = try? Data(contentsOf: entriesURL),
           let decoded = try? JSONDecoder().decode([CareEventEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Store.seedEntries()
            save()
        }
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    static func seedEntries() -> [CareEventEntry] {
        [
            CareEventEntry(title: "Feeding", value: Double(1)),
            CareEventEntry(title: "Diaper change", value: Double(2)),
            CareEventEntry(title: "Bath", value: Double(3))
        ]
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: entriesURL, options: .atomic)
        }
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL, options: .atomic)
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeEntryLimit
    }

    @discardableResult
    func add(_ entry: CareEventEntry) -> Bool {
        guard canAddMore else { return false }
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: CareEventEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: CareEventEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func saveSettings() {
        save()
    }
}
