import Foundation

struct SessionRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let completedAt: Date
    let routineType: RoutineType
    let completedCount: Int

    init(
        id: UUID = UUID(),
        completedAt: Date,
        routineType: RoutineType,
        completedCount: Int
    ) {
        self.id = id
        self.completedAt = completedAt
        self.routineType = routineType
        self.completedCount = completedCount
    }
}
