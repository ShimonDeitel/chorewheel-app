import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [ChorewheelEntry] = []
    @Published var categoryFiltersEnabled: Bool = true

    /// Free-tier cap on total entries. Kept well above seed data count
    /// so a fresh install never trips the paywall immediately.
    static let freeEntryLimit = 15

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("Chorewheel", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("entries.json")
        load()
    }

    var isAtFreeLimit: Bool {
        entries.count >= Store.freeEntryLimit
    }

    func add(_ entry: ChorewheelEntry) -> Bool {
        guard !isAtFreeLimit else { return false }
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: ChorewheelEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: ChorewheelEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([ChorewheelEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Store.seedData()
            save()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [ChorewheelEntry] {
        [
        ChorewheelEntry(isDone: false, childName: "Ava", reward: "0.50"),
        ChorewheelEntry(isDone: false, childName: "Ben", reward: "0.50"),
        ChorewheelEntry(isDone: false, childName: "Ava", reward: "1.00")
        ]
    }
}
