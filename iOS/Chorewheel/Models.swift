import Foundation

struct ChorewheelEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var isDone: Bool
    var childName: String
    var reward: String

    init(id: UUID = UUID(), createdAt: Date = Date(), isDone: Bool = false, childName: String = "", reward: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.isDone = isDone
        self.childName = childName
        self.reward = reward
    }
}
