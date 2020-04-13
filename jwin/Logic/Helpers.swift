import UIKit

enum DebugError: Error {
    case debug(String)
}

struct WithUUID<T>: Identifiable {
    let id = UUID()
    var value: T
}

class DatePoke: ObservableObject {
    @Published var lastPoked: Date

    init() {
        self.lastPoked = Date()
    }
    
    func poke() {
        self.lastPoked = Date()
    }
}

