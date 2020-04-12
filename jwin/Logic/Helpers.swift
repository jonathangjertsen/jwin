import UIKit

extension Double {
    func clamp(between lower: Double, and upper: Double) -> Double {
        return min(max(self, lower), upper)
    }
}

extension DateFormatter {
    static let reminderFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
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

func inMainThread(_ code: @escaping () -> ()) {
    DispatchQueue.main.async {
        code()
    }
}
