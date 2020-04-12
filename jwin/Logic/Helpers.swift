import UIKit

extension Double {
    func clamp(between lower: Double, and upper: Double) -> Double {
        return min(max(self, lower), upper)
    }
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
